import 'package:dashboard/features/comic/manhuatai/manhuatai_library_page_state.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:flutter/material.dart';

/// 书架 (favourites + reading history), backed by [ManhuataiLibraryStore].
///
/// The source had a server-side bookshelf (`getuserrecord` +
/// `setusercollect`) plus the local `HasReadChaptersDbProvider`; this port keeps
/// the same two lists, persisted locally.
class ManhuataiLibraryPage extends StatefulWidget {
  const ManhuataiLibraryPage({
    super.key,
    required this.store,
    this.source,
    this.initialTab = 0,
  });

  final ManhuataiLibraryStore store;
  final ManhuataiSource? source;
  final int initialTab;

  @override
  State<ManhuataiLibraryPage> createState() => ManhuataiLibraryPageState();
}
