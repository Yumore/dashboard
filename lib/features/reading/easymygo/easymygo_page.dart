import 'package:dashboard/features/reading/easymygo/easymygo_page_state.dart';
import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/service/reading_service.dart';
import 'package:flutter/material.dart';

/// EasyMyGo module entry (the widget the Lead registers in the reading hub).
///
/// The page owns the bootstrap of the ported engine ([ReadingService]) and hands
/// it to the sub-screens: shelf/history, search, source management.
class EasyMyGoPage extends StatefulWidget {
  const EasyMyGoPage({super.key, this.service, this.libraryStore});

  /// Injected by tests; production bootstraps from `shared_preferences`.
  final ReadingService? service;
  final LibraryStore? libraryStore;

  @override
  State<EasyMyGoPage> createState() => EasyMyGoPageState();
}
