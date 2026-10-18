import 'package:dashboard/features/comic/picacomic/controllers/picacomic_explore_controller.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_home_page_state.dart';
import 'package:flutter/material.dart';

/// Home (explore) screen of the picacomic module.
///
/// Ports PicaComic lib/pages/explore_page.dart: one tab per explore page of the
/// selected source, one section per `ExplorePagePart`, and "view more" links
/// encoded as `category:<name>` / `search:<keyword>`.
class PicacomicHomePage extends StatefulWidget {
  const PicacomicHomePage({this.controller, super.key});

  /// Injected by tests; defaults to a registry-backed controller.
  final PicacomicExploreController? controller;

  @override
  State<PicacomicHomePage> createState() => PicacomicHomePageState();
}
