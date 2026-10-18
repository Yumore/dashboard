import 'package:dashboard/features/movie/yyets/yyets_file_link.dart';
import 'package:dashboard/features/movie/yyets/yyets_json.dart';

/// 一种压制格式，对应资源详情 `item_list` 的一项。
///
/// 字段来自源工程 `ResInfoPage.buildBody` 的 `headerBuilder`：
///
/// ```dart
/// (item['format_tip'] ?? "") + "\t\t\t" + (item['foramt'] ?? "")
/// item['size']
/// formatSeconds(int.parse(item['dateline']))
/// List fs = item['files'];
/// ```
///
/// 注意源工程把 `format` 拼错成了 `foramt`，接口实际返回的也是 `foramt`，
/// 因此 [format] 仍然读 `foramt` (typo preserved)，不能“顺手修正”。
class YyetsEdition {
  const YyetsEdition({
    this.formatTip = '',
    this.format = '',
    this.size = '',
    this.dateline,
    this.files = const <YyetsFileLink>[],
  });

  /// `format_tip` —— 例如 `HR-HDTV`、`MP4`。
  final String formatTip;

  /// `foramt`（接口原字段名，源工程拼写错误）。
  final String format;

  /// `size` —— 源工程 `item['size']?.toString()`，空则不显示。
  final String size;

  /// `dateline` —— 秒级时间戳；源工程 `int.parse`，解析失败会崩。
  final int? dateline;

  /// `files`
  final List<YyetsFileLink> files;

  bool get hasSize => size.trim().isNotEmpty;

  /// 源工程头部第一行：`format_tip` + 三个 tab + `foramt`，最后 trim。
  String get formatLabel {
    final tip = formatTip.trim();
    final name = format.trim();
    return '$tip\t\t\t$name'.trim();
  }

  /// 源工程 `ExpansionPanel` 默认展开第一项：`i == resList[0]`。
  bool isDefaultExpanded(int index) => index == 0;

  List<YyetsFileLink> get launchableFiles =>
      files.where((file) => file.hasAddress).toList(growable: false);

  factory YyetsEdition.fromJson(Map<String, dynamic> json) => YyetsEdition(
    formatTip: YyetsJson.asString(json['format_tip']),
    format: YyetsJson.asString(json['foramt']),
    size: YyetsJson.asString(json['size']),
    dateline: YyetsJson.asNullableInt(json['dateline']),
    files: YyetsJson.asMapList(
      json['files'],
    ).map(YyetsFileLink.fromJson).toList(growable: false),
  );
}
