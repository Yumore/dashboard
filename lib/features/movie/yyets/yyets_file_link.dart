import 'package:dashboard/features/movie/yyets/yyets_json.dart';

/// 资源详情里的一条下载/播放链接。
///
/// 对应源工程 `ResInfoPage.buildBody` 里 `item['files']` 的元素：
///
/// ```dart
/// String addr = file['address'];
/// String pwd  = file['passwd'];
/// Text("way: " + file['way'].toString());
/// Text(file['way_name'] ?? "");
/// ```
class YyetsFileLink {
  const YyetsFileLink({
    required this.address,
    this.passwd,
    this.way,
    this.wayName = '',
  });

  /// `address` —— 网盘 / 磁力 / 直链地址。
  final String address;

  /// `passwd` —— 网盘提取码，源工程在点击时复制到剪贴板。
  final String? passwd;

  /// `way` —— 网盘渠道编号，源工程原样 `toString()` 后显示。
  final int? way;

  /// `way_name` —— 渠道名称，如 `百度网盘`、`磁力链接`。
  final String wayName;

  bool get hasAddress => address.trim().isNotEmpty;

  /// 源工程 `if (pwd != null && pwd.isNotEmpty)` 的显式版本。
  bool get hasPasswd => passwd != null && passwd!.isNotEmpty;

  /// 源工程 `LatestResourcePage.requestDownload` 的显示拼接：
  /// `addr + "\n密码：" + pwd`。
  String get displayText => hasPasswd ? '$address\n密码：$passwd' : address;

  /// 是否是磁力链接——源工程用 `launchUri` 交给迅雷等外部应用。
  bool get isMagnet => address.toLowerCase().startsWith('magnet:');

  /// 是否是 `ed2k` 链接（源工程同样交给外部下载器）。
  bool get isEd2k => address.toLowerCase().startsWith('ed2k:');

  /// 源工程 `ResInfoPage` 的 `launchUri(addr)`：能被 url_launcher 打开的链接。
  bool get isLaunchable =>
      isMagnet ||
      isEd2k ||
      address.startsWith('http://') ||
      address.startsWith('https://');

  factory YyetsFileLink.fromJson(Map<String, dynamic> json) => YyetsFileLink(
    address: YyetsJson.asString(json['address']),
    passwd: YyetsJson.asNullableString(json['passwd']),
    way: YyetsJson.asNullableInt(json['way']),
    wayName: YyetsJson.asString(json['way_name']),
  );

  /// 源工程 `Text("way: " + file['way'].toString() ?? "")`。
  String get wayLabel => 'way: ${way ?? ''}';
}
