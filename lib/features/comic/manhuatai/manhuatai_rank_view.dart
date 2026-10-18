import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_view_state.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:flutter/material.dart';

/// 排行 tab. Ported from the source's `HomeRankPage` + `ComicRankPage`
/// (`getRankTypes` + `getIndexRankData` + `getRankDataDetials`).
class ManhuataiRankView extends StatefulWidget {
  const ManhuataiRankView({super.key, required this.source, this.store});

  final ManhuataiSource source;
  final ManhuataiLibraryStore? store;

  @override
  State<ManhuataiRankView> createState() => ManhuataiRankViewState();
}
