import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_search_page_state.dart';
import 'package:flutter/material.dart';

/// 开眼 search: hot keyword chips, then paged results.
///
/// Port of `module_home/lib/page/video_search_page.dart` +
/// `module_home/lib/viewmodel/video_search_model.dart`. The source's result rows
/// dropped any hit without a cover, and the port keeps that filter.
class EyepetizerSearchPage extends StatefulWidget {
  const EyepetizerSearchPage({this.api, this.initialQuery, super.key});

  /// Injectable transport. When null the page builds and owns one.
  final EyepetizerApi? api;

  /// Runs the search immediately instead of showing the keyword chips.
  final String? initialQuery;

  @override
  State<EyepetizerSearchPage> createState() => EyepetizerSearchPageState();
}
