import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_home_page_state.dart';
import 'package:flutter/material.dart';

/// The 开眼 home feed — the module entry point.
///
/// Port of `module_home/lib/page/home_page.dart` + `home_tab_page.dart`
/// (a carousel followed by a paged video list). The source's app shell around it
/// (splash, bottom navigation, theme, `SmartRefresher`, `oktoast`) is not
/// ported; the host's own shell mounts this page.
///
/// The source reached search and categories from a separate "discover" tab.
/// Since the host mounts exactly one widget here, both entry points are exposed
/// as app-bar actions instead.
class EyepetizerHomePage extends StatefulWidget {
  const EyepetizerHomePage({this.api, this.bannerAutoPlay = true, super.key});

  /// Injectable transport. When null the page builds and owns one.
  final EyepetizerApi? api;

  /// Widget tests set this false: an autoplaying carousel never lets
  /// `pumpAndSettle` settle.
  final bool bannerAutoPlay;

  @override
  State<EyepetizerHomePage> createState() => EyepetizerHomePageState();
}
