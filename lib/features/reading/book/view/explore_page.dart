import 'package:dashboard/features/reading/book/view/explore_page_state.dart';
import 'package:flutter/material.dart';

/// Source-explore ("发现") screen.
///
/// Ported from `book/lib/view/book/explore_page.dart` +
/// `explore_source_picker_sheet.dart`, merged into one page that lets the user
/// pick an explore-capable source and one of its @ref parseExploreKinds kinds.
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => ExplorePageState();
}
