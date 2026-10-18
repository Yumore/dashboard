import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category_page_state.dart';
import 'package:flutter/material.dart';

/// Every 开眼 category, as a two-column grid.
///
/// Port of `module_discover/lib/page/category_page.dart`. The source reached it
/// from the "discover" tab; the host reaches it from the home app bar.
class EyepetizerCategoryPage extends StatefulWidget {
  const EyepetizerCategoryPage({this.api, super.key});

  /// Injectable transport. When null the page builds and owns one.
  final EyepetizerApi? api;

  @override
  State<EyepetizerCategoryPage> createState() => EyepetizerCategoryPageState();
}
