import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_update_view_state.dart';
import 'package:flutter/material.dart';

/// 更新 tab. Ported from the source's `HomeUpdatePage` + `UpdateListView`
/// (`updatelist` with a `today` group and dated groups).
class ManhuataiUpdateView extends StatefulWidget {
  const ManhuataiUpdateView({super.key, required this.source, this.store});

  final ManhuataiSource source;
  final ManhuataiLibraryStore? store;

  @override
  State<ManhuataiUpdateView> createState() => ManhuataiUpdateViewState();
}
