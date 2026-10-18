import 'package:dashboard/features/anime/tsdm/tsdm_forum_group_page_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:flutter/material.dart';

/// Forum group page: the list of forums inside a forum group.
///
/// Ported from `tsdm_client/lib/features/forum/view/forum_group_page.dart`.
class TsdmForumGroupPage extends StatefulWidget {
  /// Create a forum group page of group [gid].
  const TsdmForumGroupPage({
    required this.gid,
    this.title,
    this.client,
    this.repository,
    super.key,
  });

  /// Forum group id.
  final String gid;

  /// Optional group title.
  final String? title;

  /// Injected transport, a new one is created when omitted.
  final TsdmHttpClient? client;

  /// Injected repository, built from [client] when omitted.
  final TsdmForumRepository? repository;

  @override
  State<TsdmForumGroupPage> createState() => TsdmForumGroupPageState();
}
