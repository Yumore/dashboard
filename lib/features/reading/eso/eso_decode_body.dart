import 'dart:convert';
import 'dart:typed_data';

import 'package:enough_convert/enough_convert.dart';

/// 响应体解码（移植 eso `lib/utils/decode_body.dart` 的 `DecodeBody`）。
///
/// 与原实现的差异：GBK 表（源文件里手写的 24000 行映射）改用宿主已有的
/// `enough_convert` 的 `gbk` 编解码器，语义一致。
class EsoDecodeBody {
  static final RegExp charsetPattern = RegExp('charset', caseSensitive: false);

  static final RegExp charsetValuePattern =
      RegExp(r"""charset\s*\=[\s"']*([^"';\s]+)""", caseSensitive: false);

  String decode(Uint8List bodyBytes, String? contentType) {
    if (bodyBytes.isEmpty) return '';
    if (contentType != null && contentType.isNotEmpty) {
      if (contentType.contains(charsetPattern)) {
        final match = charsetValuePattern.firstMatch(contentType);
        final charset = (match?.group(1) ?? '').toLowerCase();
        return _decodeWithCharset(charset, bodyBytes);
      } else if (contentType.contains('json')) {
        return utf8.decode(bodyBytes);
      }
    }
    return _autoDecode(bodyBytes);
  }

  String _decodeWithCharset(String charset, Uint8List bodyBytes) {
    if (charset.contains('gb')) {
      return gbk.decode(bodyBytes);
    }
    final encoding = Encoding.getByName(charset);
    if (encoding == null || encoding is Utf8Codec) {
      return utf8.decode(bodyBytes, allowMalformed: true);
    }
    if (encoding is AsciiCodec) {
      return ascii.decode(bodyBytes, allowInvalid: true);
    }
    if (encoding is Latin1Codec) {
      return latin1.decode(bodyBytes, allowInvalid: true);
    }
    return encoding.decode(bodyBytes);
  }

  String _autoDecode(Uint8List bodyBytes) {
    var srcIndex = 0;
    final sb = StringBuffer();
    while (srcIndex < bodyBytes.length) {
      final byte = bodyBytes[srcIndex++];
      if (byte < 0x80) {
        sb.writeCharCode(byte);
      } else {
        srcIndex--;
        break;
      }
    }
    final leftBytes = bodyBytes.sublist(srcIndex);

    String? charset;
    var temp = sb.toString();
    if (temp.trimLeft().startsWith('{') || temp.trimLeft().startsWith('[')) {
      return temp + utf8.decode(leftBytes, allowMalformed: true);
    }
    if (temp.contains(charsetPattern)) {
      charset = charsetValuePattern.firstMatch(temp)?.group(1)?.toLowerCase();
    } else {
      temp += utf8.decode(leftBytes, allowMalformed: true);
      if (temp.contains(charsetPattern)) {
        charset = charsetValuePattern.firstMatch(temp)?.group(1)?.toLowerCase();
      }
      if (charset == null || charset.contains('utf8') || charset.contains('utf-8')) {
        return temp;
      }
    }
    if (charset != null && charset.contains('gb')) {
      return sb.toString() + gbk.decode(leftBytes);
    }
    final encoding = charset == null ? null : Encoding.getByName(charset);
    if (encoding == null || encoding is Utf8Codec) {
      return temp + utf8.decode(leftBytes, allowMalformed: true);
    }
    if (encoding is AsciiCodec) {
      return temp + ascii.decode(leftBytes, allowInvalid: true);
    }
    if (encoding is Latin1Codec) {
      return temp + latin1.decode(leftBytes, allowInvalid: true);
    }
    return temp + encoding.decode(leftBytes);
  }
}
