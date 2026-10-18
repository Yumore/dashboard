import 'package:dashboard/features/comic/picacomic/controllers/picacomic_search_controller.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_search_page_state.dart';
import 'package:flutter/material.dart';

/// Search screen of the picacomic module.
///
/// Ports PicaComic lib/pages/search_result_page.dart: keyword + per-source
/// option groups, paged results, and the "no source selected" case.
class PicacomicSearchPage extends StatefulWidget {
  const PicacomicSearchPage({
    this.controller,
    this.initialKeyword,
    this.sourceKey,
    super.key,
  });

  final PicacomicSearchController? controller;
  final String? initialKeyword;

  /// When set, the page pre-selects this source (used by explore "search:...".
  final String? sourceKey;

  @override
  State<PicacomicSearchPage> createState() => PicacomicSearchPageState();
}
