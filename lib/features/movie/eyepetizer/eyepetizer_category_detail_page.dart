import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category_detail_page_state.dart';
import 'package:flutter/material.dart';

/// One category's videos.
///
/// Port of `module_discover/lib/page/category_detail_page.dart`: a collapsing
/// header over a paged list of videos, where the title flips between white and
/// black as the header expands (see `EyepetizerCollapse`).
class EyepetizerCategoryDetailPage extends StatefulWidget {
  const EyepetizerCategoryDetailPage({
    required this.category,
    this.api,
    super.key,
  });

  final EyepetizerCategory category;

  /// Injectable transport. When null the page builds and owns one.
  final EyepetizerApi? api;

  @override
  State<EyepetizerCategoryDetailPage> createState() =>
      EyepetizerCategoryDetailPageState();
}
