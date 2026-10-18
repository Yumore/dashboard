import 'dart:convert';
import 'dart:io';

import 'package:dashboard/features/reading/eso/eso_rule.dart';

/// eso 书源分享串的压缩/解压（移植 `lib/utils/rule_comparess.dart`）。
///
/// 分享串格式：`eso://<author>:<name>@<base64(gzip(json))>`。
/// 原实现依赖 `package:archive` 的 GZipDecoder，宿主无该依赖，改用 `dart:io`
/// 自带的 [gzip] 编解码器（压缩格式一致，可互相解压）。
class EsoRuleCompress {
  const EsoRuleCompress._();

  static const String tag = 'eso://';

  /// 取出 `@` 之后的 base64、gunzip、utf8 解码为 JSON 字符串。
  static String decompressString(String text, [EsoRule? rule]) {
    final lastIndex = text.lastIndexOf('@');
    final gzipBytes = base64Decode(text.substring(lastIndex + 1));
    try {
      return utf8.decode(gzip.decode(gzipBytes));
    } catch (_) {
      // Web 没有 dart:io 的 gzip 编解码器：明确提示而不是抛出平台异常。
      throw const FormatException('当前平台不支持导入压缩书源');
    }
  }

  static EsoRule decompress(String text, [EsoRule? rule]) =>
      EsoRule.fromJson(jsonDecode(decompressString(text, rule)), rule);

  /// 把单个书源压成分享串。
  static String compress(EsoRule rule) {
    final jsonBytes = utf8.encode(jsonEncode(rule.toJson()));
    final List<int> gzipBytes;
    try {
      gzipBytes = gzip.encode(jsonBytes);
    } catch (_) {
      throw const FormatException('当前平台不支持导出压缩书源');
    }
    return '$tag${rule.author}:${rule.name}@${base64.encode(gzipBytes)}';
  }

  /// 批量分享：JSON 数组，每项是一个分享串。
  static String compressMany(List<EsoRule> rules) =>
      jsonEncode(rules.map(compress).toList());
}
