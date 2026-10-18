/// 一条已下载记录。字段与源工程写进 sembast 的那张 map 一致：
/// `{'id', 'path', 'image', 'size', 'name'}`（`size` 是
/// [FeedbooksFormat.formatBytes] 格式化后的字符串，如 `1.2 MB`）。
///
/// 源工程把原始 map 直接塞给 UI，移植版在存储边界保持同样的 JSON 键，
/// 对外给类型化对象。
class FeedbooksDownloadRecord {
  const FeedbooksDownloadRecord({
    required this.id,
    required this.path,
    required this.image,
    required this.size,
    required this.name,
  });

  factory FeedbooksDownloadRecord.fromMap(Map<String, dynamic> map) {
    return FeedbooksDownloadRecord(
      id: map['id'] as String? ?? '',
      path: map['path'] as String? ?? '',
      image: map['image'] as String? ?? '',
      size: map['size'] as String? ?? '',
      name: map['name'] as String? ?? '',
    );
  }

  final String id;
  final String path;
  final String image;
  final String size;
  final String name;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'path': path,
    'image': image,
    'size': size,
    'name': name,
  };

  @override
  String toString() => 'FeedbooksDownloadRecord($id, $name, $size)';
}
