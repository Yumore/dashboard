import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';

/// Ports lib/network/picacg_network/headers.dart.
///
/// The signature is the load-bearing business rule of the Picacg source: a
/// HMAC-SHA256 over `path + time + nonce + METHOD + apiKey` keyed with a
/// hard-coded secret, sent alongside the api-key header.
const String picacgApiKey = 'C69BAF41DA5ABD1FFEDC6D2FEA56B';

/// The HMAC secret, byte-for-byte identical to PicaComic's `headers.dart`.
const String picacgSignatureSecret =
    '~d}\$Q7\$eIni=V)9\\RK/P.RM4;9[7|@/CA}b~OW!3?EV`:<>M7pddUBL5n|0/*Cn';

/// Number of 100-ns intervals between 1582-10-15 and 1970-01-01.
const int _gregorianToUnix100Ns = 0x01B21DD213814000;

final math.Random _secureRandom = math.Random.secure();

String _hex(int value, int width) =>
    value.toRadixString(16).padLeft(width, '0').substring(0, width);

/// PicaComic used `const Uuid().v1().replaceAll('-', '')`.
///
/// `uuid` is not a host dependency, so the v1 layout is written out here.
/// [timestampMicros], [clockSequence] and [node] let tests pin the value.
String createNonce({
  int? timestampMicros,
  int? clockSequence,
  List<int>? node,
}) {
  final micros = timestampMicros ?? DateTime.now().microsecondsSinceEpoch;
  final timestamp = micros * 10 + _gregorianToUnix100Ns;
  final timeLow = timestamp & 0xFFFFFFFF;
  final timeMid = (timestamp >> 32) & 0xFFFF;
  final timeHigh = ((timestamp >> 48) & 0x0FFF) | 0x1000;

  final sequence = (clockSequence ?? _secureRandom.nextInt(1 << 14)) & 0x3FFF;
  final seqHigh = ((sequence >> 8) & 0x3F) | 0x80;
  final seqLow = sequence & 0xFF;

  final nodeBytes = node ?? List<int>.generate(6, (_) => _secureRandom.nextInt(256));
  if (nodeBytes.length != 6) {
    throw ArgumentError.value(node, 'node', 'must hold exactly 6 bytes');
  }
  final nodeFirst = (nodeBytes[0] | 0x01) & 0xFF;

  return _hex(timeLow, 8) +
      _hex(timeMid, 4) +
      _hex(timeHigh, 4) +
      _hex(seqHigh, 2) +
      _hex(seqLow, 2) +
      _hex(nodeFirst, 2) +
      nodeBytes.skip(1).map((byte) => _hex(byte & 0xFF, 2)).join();
}

/// Ports `createSignature(path, nonce, time, method)` verbatim.
String createSignature(
  String path,
  String nonce,
  String time,
  String method,
) {
  final key = path + time + nonce + method + picacgApiKey;
  final digest = Hmac(sha256, utf8.encode(picacgSignatureSecret))
      .convert(utf8.encode(key.toLowerCase()));
  return digest.toString();
}

/// Ports `getHeaders(...)` from headers.dart as a plain map.
Map<String, String> buildPicacgHeaders({
  required String method,
  required String token,
  required String url,
  String? appChannel,
  String? imageQuality,
  String? nonce,
  int? timestampSeconds,
}) {
  final requestNonce = nonce ?? createNonce();
  final time =
      (timestampSeconds ?? DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();
  return <String, String>{
    'api-key': picacgApiKey,
    'accept': 'application/vnd.picacomic.com.v1+json',
    'app-channel': appChannel ?? '3',
    'authorization': token,
    'time': time,
    'nonce': requestNonce,
    'app-version': '2.2.1.3.3.4',
    'app-uuid': 'defaultUuid',
    'image-quality': imageQuality ?? 'original',
    'app-platform': 'android',
    'app-build-version': '45',
    'Content-Type': 'application/json; charset=UTF-8',
    'user-agent': 'okhttp/3.8.1',
    'version': 'v1.4.1',
    'Host': 'picaapi.picacomic.com',
    'signature': createSignature(
      url,
      requestNonce,
      time,
      method.toUpperCase(),
    ),
  };
}
