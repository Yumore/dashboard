import 'package:dashboard/features/comic/picacomic/controllers/picacomic_category_controller.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_category_page_state.dart';
import 'package:flutter/material.dart';

/// Category screen of the picacomic module.
///
/// Ports PicaComic lib/pages/category_page.dart + category_comics_page.dart:
/// part tabs, category chips, the source's option groups and the ranking menu.
class PicacomicCategoryPage extends StatefulWidget {
  const PicacomicCategoryPage({
    this.controller,
    this.sourceKey,
    this.initialCategory,
    this.initialParam,
    super.key,
  });

  final PicacomicCategoryController? controller;

  /// Pre-selects a source (explore "category:..." links carry the key).
  final String? sourceKey;

  /// Loaded directly, even when it is not part of a part (e.g. `random`).
  final String? initialCategory;

  final String? initialParam;

  @override
  State<PicacomicCategoryPage> createState() => PicacomicCategoryPageState();
}
