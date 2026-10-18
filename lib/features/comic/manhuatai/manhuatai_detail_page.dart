import 'package:dashboard/features/comic/manhuatai/manhuatai_detail_page_state.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:flutter/material.dart';

/// Comic detail (`getcomicinfo_body` + `getcomicinfo_influence` +
/// `comment/count`), with the chapter list and the local favourite toggle.
class ManhuataiDetailPage extends StatefulWidget {
  const ManhuataiDetailPage({
    super.key,
    required this.comicId,
    this.source,
    this.store,
  });

  final int comicId;
  final ManhuataiSource? source;
  final ManhuataiLibraryStore? store;

  @override
  State<ManhuataiDetailPage> createState() => ManhuataiDetailPageState();
}
