import 'package:dashboard/features/anime/tsdm/tsdm_filter_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_page_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:flutter/material.dart';

/// Forum display page of the tsdm forum.
///
/// Ported from `tsdm_client/lib/features/forum/view/forum_page.dart`: the page
/// shows the pinned threads, the normal threads and the sub forums of a forum
/// and supports paging and thread filtering.
class TsdmForumPage extends StatefulWidget {
  /// Create a forum page of forum [fid].
  const TsdmForumPage({
    required this.fid,
    this.title,
    this.filterState,
    this.client,
    this.repository,
    super.key,
  });

  /// Forum id.
  final String fid;

  /// Optional forum title shown before the first page has been loaded.
  final String? title;

  /// Initial filters.
  final TsdmFilterState? filterState;

  /// Injected transport, a new one is created when omitted.
  final TsdmHttpClient? client;

  /// Injected repository, built from [client] when omitted.
  final TsdmForumRepository? repository;

  @override
  State<TsdmForumPage> createState() => TsdmForumPageState();
}
