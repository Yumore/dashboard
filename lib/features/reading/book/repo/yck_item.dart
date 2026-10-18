import 'package:dashboard/features/reading/book/importer/source_importer.dart';
import 'package:dashboard/features/reading/book/repo/yck_kind.dart';
import 'package:dashboard/features/reading/book/repo/yckceo_repo.dart';

/// Kind of yckceo catalog entry.
class YckItem {
  final String id;
  final String title;
  final String? host;
  final String? updated;
  final int? downloads;
  final YckKind kind;

  const YckItem({
    required this.id,
    required this.title,
    this.host,
    this.updated,
    this.downloads,
    this.kind = YckKind.source,
  });

  bool get isCollection => kind == YckKind.collection;
  bool get isRss => kind == YckKind.rss;

  /// 可直接交给 [SourceImporter.fromUrl] 的 JSON 地址。
  String get jsonUrl {
    switch (kind) {
      case YckKind.collection:
        return '${YckceoRepo.base}/yuedu/shuyuans/json/id/$id.json';
      case YckKind.rss:
        return '${YckceoRepo.base}/yuedu/rss/json/id/$id.json';
      case YckKind.source:
        return '${YckceoRepo.base}/yuedu/shuyuan/json/id/$id.json';
    }
  }
}

