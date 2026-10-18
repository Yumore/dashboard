/// 电影天堂列表行与详情共用的模型。
///
/// JSON 字段名与源工程 `lib/movie_detail.dart` 完全一致。源工程在列表
/// 解析时直接把缺字段赋给非空 `String`（旧版非空安全代码），宿主在
/// 空安全下把缺失字段落成空串：列表接口本来只返回 `id`、`categoryId`、
/// `name`、`publishTime`，这样做才不会让整个列表解析失败。
class DyttMovieDetail {
  const DyttMovieDetail({
    required this.id,
    required this.categoryId,
    required this.name,
    this.publishTime = '',
    this.homePicUrl = '',
    this.pics = '',
    this.downloadUrl = '',
    this.content = '',
    this.isPrefect = false,
  });

  factory DyttMovieDetail.fromJson(Map<String, dynamic> json) {
    return DyttMovieDetail(
      id: _requiredInt(json['id'], 'id'),
      categoryId: _requiredInt(json['categoryId'], 'categoryId'),
      name: _string(json['name']),
      publishTime: _string(json['publishTime']),
      homePicUrl: _string(json['homePicUrl']),
      pics: _string(json['pics']),
      downloadUrl: _string(json['downloadUrl']),
      content: _string(json['content']),
    );
  }

  final int id;
  final int categoryId;
  final String name;
  final String publishTime;
  final String homePicUrl;
  final String pics;
  final String downloadUrl;
  final String content;

  /// 源工程用它标记「列表项已用详情覆盖」的本地状态，不来自服务端；
  /// 宿主不在列表里偷偷请求详情，所以只保留字段与默认值。
  final bool isPrefect;

  /// 与源工程同样的 8 个键（`isPrefect` 不参与序列化）。
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'categoryId': categoryId,
    'name': name,
    'publishTime': publishTime,
    'homePicUrl': homePicUrl,
    'content': content,
    'pics': pics,
    'downloadUrl': downloadUrl,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DyttMovieDetail &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          categoryId == other.categoryId;

  @override
  int get hashCode => id.hashCode ^ categoryId.hashCode;

  @override
  String toString() => 'DyttMovieDetail($id, $categoryId, $name)';
}

int _requiredInt(Object? value, String key) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  final parsed = int.tryParse(value?.toString() ?? '');
  if (parsed == null) {
    throw FormatException('电影天堂 JSON 缺少整数字段 $key');
  }
  return parsed;
}

String _string(Object? value) => value == null ? '' : '$value';
