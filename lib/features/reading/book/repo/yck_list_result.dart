import 'package:dashboard/features/reading/book/repo/yck_item.dart';

/// Kind of yckceo catalog entry.
class YckListResult {
  final List<YckItem> items;
  final int total;
  final int page;
  final int pageSize;

  const YckListResult({
    required this.items,
    required this.total,
    required this.page,
    this.pageSize = 100,
  });

  bool get hasMore => page * pageSize < total;
}

/// 源仓库目录抓取（HTML 列表页 + 官方 JSON 直链）。
///
/// 不附带任何书源内容；仅提供浏览与用户主动导入。
