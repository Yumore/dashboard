import 'package:dashboard/features/reading/book/view/reader_settings_page_state.dart';
import 'package:flutter/material.dart';

/// Reader typography / paper / page-turn settings sheet.
///
/// Ported from `book/lib/view/book/reader_menu.dart` settings pane (the source
/// also had a font-file picker backed by `file_picker`, which is not a host
/// dependency and is therefore not ported).
class ReaderSettingsPage extends StatefulWidget {
  const ReaderSettingsPage({super.key, this.onChanged});

  /// Invoked after any setting changes so the reader can re-paginate.
  final VoidCallback? onChanged;

  @override
  State<ReaderSettingsPage> createState() => ReaderSettingsPageState();
}
