import 'package:dashboard/features/comic/manhuatai/manhuatai_category_page_state.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:flutter/material.dart';

/// 分类 / 排序列表 (`getsortlist`), paged through `page.current_page`.
class ManhuataiCategoryPage extends StatefulWidget {
  const ManhuataiCategoryPage({super.key, required this.source, this.store});

  final ManhuataiSource source;
  final ManhuataiLibraryStore? store;

  @override
  State<ManhuataiCategoryPage> createState() => ManhuataiCategoryPageState();
}
