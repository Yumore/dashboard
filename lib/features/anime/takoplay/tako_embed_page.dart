import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

/// The AES material the gogoplay embed page hands out, ported from the
/// source's `extractor.extract` (`lib/utils/extractor.dart:16-61`).
///
/// The page hides five values in attribute *positions*:
/// * `div.wrapper`'s class suffix after `container-` is the IV,
/// * `body`'s class suffix after `container-` is the secret key,
/// * `div.videocontent`'s class suffix after `videocontent-` is the decrypt key,
/// * the third `<script>`'s last attribute value is the encrypted ajax params,
/// * the first `<input>`'s last attribute value is the plain anime id.
class TakoEmbedPage {
  const TakoEmbedPage({
    required this.iv,
    required this.secretKey,
    required this.decryptKey,
    required this.scriptCipher,
    required this.animeId,
  });

  factory TakoEmbedPage.parse(String source) {
    final document = html.parse(source);
    return TakoEmbedPage(
      iv: _classSuffix(document, 'wrapper', 'container-'),
      secretKey: _tagSuffix(document, 'body', 'container-'),
      decryptKey: _classSuffix(document, 'videocontent', 'videocontent-'),
      scriptCipher: _scriptCipher(document),
      animeId: _inputValue(document),
    );
  }

  /// AES-CBC IV (16 characters).
  final String iv;

  /// AES-CBC key used for the script payload and the anime id (16 characters).
  final String secretKey;

  /// AES-CBC key of the `encrypt-ajax.php` `data` field (16 characters).
  final String decryptKey;

  /// Base64 ciphertext of `&token=...&expires=...`.
  final String scriptCipher;

  /// Plain `anime_id`; `alias=` of the ajax request.
  final String animeId;

  static String _classSuffix(
    dom.Document document,
    String className,
    String marker,
  ) {
    final elements = document.getElementsByClassName(className);
    if (elements.isEmpty) {
      throw FormatException('embed page has no .$className element');
    }
    return _after(elements.first.attributes.values, marker, '.$className');
  }

  static String _tagSuffix(dom.Document document, String tag, String marker) {
    final elements = document.getElementsByTagName(tag);
    if (elements.isEmpty) {
      throw FormatException('embed page has no <$tag> element');
    }
    return _after(elements.first.attributes.values, marker, '<$tag>');
  }

  static String _scriptCipher(dom.Document document) {
    final scripts = document.getElementsByTagName('script');
    if (scripts.length < 3) {
      throw const FormatException('embed page has fewer than three scripts');
    }
    final values = scripts[2].attributes.values.toList();
    if (values.isEmpty || values.last.isEmpty) {
      throw const FormatException('third script carries no ciphertext');
    }
    return values.last;
  }

  static String _inputValue(dom.Document document) {
    final inputs = document.getElementsByTagName('input');
    if (inputs.isEmpty) {
      throw const FormatException('embed page has no <input> element');
    }
    final values = inputs.first.attributes.values.toList();
    if (values.isEmpty || values.last.isEmpty) {
      throw const FormatException('anime id input carries no value');
    }
    return values.last;
  }

  static String _after(Iterable<String> values, String marker, String where) {
    if (values.isEmpty) {
      throw FormatException('$where has no attributes');
    }
    final parts = values.first.split(marker);
    if (parts.length < 2 || parts[1].isEmpty) {
      throw FormatException('$where does not contain $marker');
    }
    return parts[1];
  }

  @override
  String toString() => 'TakoEmbedPage(iv: $iv, decryptKey: $decryptKey)';
}
