import 'package:dashboard/features/movie/yyets/yyets_json.dart';

/// 资源文件条目，对应 `file.apicvn.com` 列表/搜索返回的元素。
///
/// 字段来自源工程两个消费点：
///
/// * `LatestResourcePage.buildItem` —— `file_name`、`create_time`、`file_size`、`fileid`
/// * `LatestResourcePage.requestDownload` —— `magnet_url`、`fileid`、`file_name`
/// * `LatestResourcePage._toUrl` —— 拼 `yyets://N=<name>|S=<size>|H=<fileid>|`
class YyetsFileEntry {
  const YyetsFileEntry({
    required this.fileId,
    this.fileName = '',
    this.fileSize = '',
    this.createTime = '',
    this.magnetUrl,
  });

  /// `fileid`
  final String fileId;

  /// `file_name`
  final String fileName;

  /// `file_size` —— 源工程直接显示字符串，没有做数值格式化。
  final String fileSize;

  /// `create_time`
  final String createTime;

  /// `magnet_url` —— 源工程把空串归一成 null。
  final String? magnetUrl;

  bool get hasMagnet => magnetUrl != null && magnetUrl!.isNotEmpty;

  /// 源工程 `LatestResourcePage._toUrl`：
  /// `yyets://N=<file_name>|S=<file_size>|H=<fileid>|`。
  String get rrUri => 'yyets://N=$fileName|S=$fileSize|H=$fileId|';

  /// 源工程 `var id = item['fileid'].hashCode; if (id > 0) id = -id;`
  /// —— 下载任务 id 是文件名哈希取负。宿主没有原生下载器，这里保留算法，
  /// 供接入下载队列时复用。
  String get taskId {
    var id = fileId.hashCode;
    if (id > 0) id = -id;
    return id.toString();
  }

  factory YyetsFileEntry.fromJson(Map<String, dynamic> json) => YyetsFileEntry(
    fileId: YyetsJson.asString(json['fileid']),
    fileName: YyetsJson.asString(json['file_name']),
    fileSize: YyetsJson.asString(json['file_size']),
    createTime: YyetsJson.asString(json['create_time']),
    magnetUrl: YyetsJson.asNullableString(json['magnet_url']),
  );
}
