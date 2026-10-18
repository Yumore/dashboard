import 'package:dashboard/features/comic/manhuatai/manhuatai_recommend_view_state.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:flutter/material.dart';

/// 推荐 tab. Ported from the source's `HomeRecommendPage` + `ManhuataiRecommend`
/// (legacy `getBookByType` sections followed by the paged `getbookbytype`).
class ManhuataiRecommendView extends StatefulWidget {
  const ManhuataiRecommendView({super.key, required this.source, this.store});

  final ManhuataiSource source;
  final ManhuataiLibraryStore? store;

  @override
  State<ManhuataiRecommendView> createState() => ManhuataiRecommendViewState();
}
