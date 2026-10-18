import 'dart:convert';

import 'package:dashboard/features/anime/takoplay/tako_aes.dart';
import 'package:dashboard/features/anime/takoplay/tako_embed_page.dart';
import 'package:dashboard/features/anime/takoplay/tako_encrypted_payload.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_endpoints.dart';
import 'package:dashboard/features/anime/takoplay/tako_stream_source.dart';
import 'package:http/http.dart' as http;

/// Port of the source's AES stream extractor
/// (`lib/utils/extractor.dart:9-133`, `Tako-Play` @ v1.6.3).
///
/// The pipeline is preserved step for step:
/// 1. GET the embed url and scrape the IV / secret key / decrypt key / script
///    ciphertext / anime id from attribute positions ([TakoEmbedPage]).
/// 2. AES-decrypt the script ciphertext with the secret key and split it into
///    `id=...` (dropped, as in the source) and the `&token=...` remainder.
/// 3. AES-encrypt the anime id with the same key and build
///    `encrypt-ajax.php?id=<encrypted id><remainder>&alias=<anime id>`.
/// 4. GET that URL with `X-Requested-With: XMLHttpRequest`.
/// 5. AES-decrypt the response's `data` field with the *decrypt* key.
/// 6. Take the first `file:` value out of the decrypted `source` array using
///    the source's own string splitting.
///
/// The only behaviour dropped is the source's artificial
/// `Future.delayed(const Duration(seconds: 1))` inside `cryptohandler`.
class TakoStreamExtractor {
  TakoStreamExtractor({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  Future<List<TakoStreamSource>> extract(String url) async {
    final page = TakoEmbedPage.parse(await _get(Uri.parse(url)));
    final aes = TakoAes(key: page.secretKey, iv: page.iv);

    final plainParams = aes.decrypt(page.scriptCipher);
    final encryptedId = aes.encrypt(page.animeId);

    final request = TakoPlayEndpoints.encryptedData(
      cdnRoot: TakoPlayEndpoints.cdnRoot(url),
      encryptedId: encryptedId,
      ajaxParams: splitAjaxParams(plainParams),
      animeId: page.animeId,
    );
    final body = await _get(request, headers: TakoPlayEndpoints.ajaxHeaders);

    final envelope = TakoEncryptedPayload.fromJson(
      jsonDecode(body) as Map<String, dynamic>,
    );
    final payload = TakoAes(
      key: page.decryptKey,
      iv: page.iv,
    ).decrypt(envelope.data);

    final fileUrl = firstFileUrl(payload);
    return [_sourceFor(fileUrl: fileUrl, payload: payload)];
  }

  /// Source lines 51-53: the plaintext is `id=...&token=...&expires=...`; the
  /// first `&`-separated chunk is dropped and the rest is the query remainder,
  /// ampersand included.
  static String splitAjaxParams(String plainParams) {
    final head = plainParams.split('&')[0];
    final parts = plainParams.split(head);
    if (parts.length < 2) return '';
    return parts[1];
  }

  /// Source lines 84-87, kept verbatim: the decrypted `source` array is
  /// stringified and the first `file:` value is split out on `,`.
  static String firstFileUrl(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map || !decoded.containsKey('source')) {
      throw const FormatException('decrypted payload has no source array');
    }
    final source = decoded['source'].toString();
    final parts = source.split('file:');
    if (parts.length < 2) {
      throw const FormatException('decrypted source array has no file url');
    }
    // `List.toString()` puts a space after `file:`; `Uri.parse` ignores it.
    return parts[1].split(',')[0].trim();
  }

  /// Enriches the extracted file with the payload's own label/type when the
  /// array is parseable, so the host player can show a quality. Falls back to
  /// the source's bare result when the payload shape is unexpected.
  TakoStreamSource _sourceFor({
    required String fileUrl,
    required String payload,
  }) {
    var label = '默认';
    var type = fileUrl.split('?').first.endsWith('.m3u8') ? 'hls' : 'mp4';
    try {
      for (final source in TakoStreamSource.listFromJson(payload)) {
        if (source.url.toString() == fileUrl) {
          if (source.label.isNotEmpty) label = source.label;
          type = source.type;
          break;
        }
      }
    } on FormatException {
      // Unexpected payload shape: keep the source's plain result.
    }
    return TakoStreamSource(label: label, url: Uri.parse(fileUrl), type: type);
  }

  Future<String> _get(Uri uri, {Map<String, String>? headers}) async {
    final response = await _client
        .get(uri, headers: headers ?? TakoPlayEndpoints.browserHeaders)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode} for $uri', uri);
    }
    return response.body;
  }

  /// Closes only the transport this extractor created itself.
  void dispose() {
    if (_ownsClient) _client.close();
  }
}
