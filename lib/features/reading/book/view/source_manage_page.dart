import 'package:dashboard/features/reading/book/view/source_manage_page_state.dart';
import 'package:flutter/material.dart';

/// Book-source management screen: list, enable/disable, delete, import JSON.
///
/// Ported from `book/lib/view/person/source_manage_page.dart`. The source also
/// shipped an online YCK/Yckceo repository browser (`source/repo/yckceo_repo.dart`
/// is ported); the browser itself lives behind [SourceManagePageState.importFromUrl].
class SourceManagePage extends StatefulWidget {
  const SourceManagePage({super.key});

  @override
  State<SourceManagePage> createState() => SourceManagePageState();
}
