import 'package:dashboard/features/novel/flutternovel/api/dmzj_v3_api.dart';
import 'package:dashboard/features/novel/flutternovel/api/zssq_api.dart';
import 'package:dashboard/features/novel/flutternovel/flutternovel_page_state.dart';
import 'package:dashboard/features/novel/flutternovel/store/flutter_novel_store.dart';
import 'package:dashboard/features/novel/flutternovel/store/novel_chapter_cache.dart';
import 'package:flutter/material.dart';

/// 网络小说 — the flutternovel module entry.
///
/// The page owns everything the feature needs: one [ZssqApi], one
/// [DmzjV3Api] (for the recommend rail) and one [FlutterNovelStore]. The menu
/// can inject its own so the module is usable offline in tests.
///
/// No network call happens in [build]: storage is opened and the shelf read
/// first, then hot words and the dmzj recommend rail are kicked off
/// asynchronously from the state's `_initialize`.
class FlutterNovelPage extends StatefulWidget {
  const FlutterNovelPage({
    super.key,
    this.api,
    this.dmzjApi,
    this.store,
    this.cache,
    this.initialTab = 0,
  });

  final ZssqApi? api;
  final DmzjV3Api? dmzjApi;
  final FlutterNovelStore? store;
  final NovelChapterCache? cache;
  final int initialTab;

  @override
  State<FlutterNovelPage> createState() => FlutterNovelPageState();
}
