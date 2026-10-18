import 'dart:convert';

/// Short stable id from sourceUrl + bookUrl.
String makeBookKey(String sourceUrl, String bookUrl) {
  return _shortHash('$sourceUrl\n$bookUrl');
}

String makeChapterId(String bookKey, String chapterUrl) {
  return _shortHash('$bookKey\n$chapterUrl');
}

/// FNV-1a 64-bit hex, good enough for local keys without extra deps.
///
/// Implemented with [BigInt] because dart2js cannot represent 64-bit integer
/// literals (`0xcbf29ce484222325`); the resulting hash is identical on the VM
/// and on the web.
String _shortHash(String input) {
  final hashMask = (BigInt.one << 64) - BigInt.one;
  final fnvOffset = BigInt.parse('cbf29ce484222325', radix: 16);
  final fnvPrime = BigInt.parse('100000001b3', radix: 16);
  var hash = fnvOffset;
  for (final b in utf8.encode(input)) {
    hash = (hash ^ BigInt.from(b)) & hashMask;
    hash = (hash * fnvPrime) & hashMask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}
