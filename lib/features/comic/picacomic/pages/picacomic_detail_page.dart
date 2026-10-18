import 'package:dashboard/features/comic/picacomic/controllers/picacomic_detail_controller.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_detail_page_state.dart';
import 'package:flutter/material.dart';

/// Comic detail screen of the picacomic module.
///
/// Ports PicaComic lib/pages/comic_page.dart (the shared detail page): cover,
/// meta info, tag groups, favourite toggle and the chapter list.
class PicacomicDetailPage extends StatefulWidget {
  const PicacomicDetailPage({
    required this.sourceKey,
    required this.comicId,
    this.title = '',
    this.cover = '',
    this.controller,
    super.key,
  });

  final String sourceKey;
  final String comicId;
  final String title;
  final String cover;
  final PicacomicDetailController? controller;

  @override
  State<PicacomicDetailPage> createState() => PicacomicDetailPageState();
}
