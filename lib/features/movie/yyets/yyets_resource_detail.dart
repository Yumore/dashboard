import 'package:dashboard/features/movie/yyets/yyets_edition.dart';
import 'package:dashboard/features/movie/yyets/yyets_json.dart';

/// `item_app` —— 源工程用 `_data['item_app']['name']` 取边下边播地址。
///
/// 宿主没有原生下载器，[name] 仍然解析出来，供“更多信息”展示或后续接入。
class YyetsItemApp {
  const YyetsItemApp({this.name = ''});

  final String name;

  bool get isEmpty => name.trim().isEmpty;

  factory YyetsItemApp.fromJson(Map<String, dynamic> json) =>
      YyetsItemApp(name: YyetsJson.asString(json['name']));
}

/// `Api.getResInfo(...)` 的响应体（`res.data['data']`）。
///
/// 这是“资源详情页”（源工程 `ResInfoPage`）真正的业务数据：一部片所有压制
/// 格式，以及每种格式下的下载/播放链接。源工程把 `item_list` 里的每条当 Map
/// 用，这里解析成 [YyetsEdition]。
class YyetsResourceDetail {
  const YyetsResourceDetail({
    this.raw = const <String, dynamic>{},
    this.editions = const <YyetsEdition>[],
    this.itemApp,
  });

  /// 原始 data，保留源工程里 `_data[...]` 的其他零散字段。
  final Map<String, dynamic> raw;

  /// `item_list`
  final List<YyetsEdition> editions;

  /// `item_app`
  final YyetsItemApp? itemApp;

  /// 源工程 `canDownPlay`：`item_app?.name != null`。
  bool get canDownloadAndPlay =>
      itemApp != null && itemApp!.name.trim().isNotEmpty;

  /// 边下边播地址（源工程 `_data['item_app']['name']`）。
  String? get downloadAndPlayUri => canDownloadAndPlay ? itemApp!.name : null;

  bool get isEmpty => editions.isEmpty;

  /// 所有格式下可点开的链接，按源工程的展示顺序展开。
  List<YyetsEdition> get editionsWithFiles => editions
      .where((edition) => edition.files.isNotEmpty)
      .toList(growable: false);

  factory YyetsResourceDetail.fromJson(Map<String, dynamic> json) {
    final appJson = YyetsJson.asMapOrNull(json['item_app']);
    return YyetsResourceDetail(
      raw: json,
      editions: YyetsJson.asMapList(
        json['item_list'],
      ).map(YyetsEdition.fromJson).toList(growable: false),
      itemApp: appJson == null ? null : YyetsItemApp.fromJson(appJson),
    );
  }

  static const YyetsResourceDetail empty = YyetsResourceDetail();
}
