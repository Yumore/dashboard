import 'package:dashboard/features/comic/manhuatai/manhuatai_home_page_state.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:flutter/material.dart';

/// Manhuatai (漫画台 / 321mh) home screen: 推荐 · 更新 · 排行 · 书架.
///
/// Ported from the source's `HomePage` + `HomeIndexPage`/`HomeRankPage`/
/// `HomeRecommendPage` and `ManhuataiPage`. Both [source] and [store] are
/// injectable so the screen can be driven from tests.
class ManhuataiHomePage extends StatefulWidget {
  const ManhuataiHomePage({super.key, this.source, this.store, this.initialIndex = 0});

  final ManhuataiSource? source;
  final ManhuataiLibraryStore? store;
  final int initialIndex;

  @override
  State<ManhuataiHomePage> createState() => ManhuataiHomePageState();
}
