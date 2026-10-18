import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_page_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_repository.dart';
import 'package:flutter/material.dart';

/// Thread detail page of the tsdm forum: title, breadcrumbs and the post list.
///
/// Ported from `tsdm_client/lib/features/thread/v1/view/thread_page.dart`.
class TsdmThreadPage extends StatefulWidget {
  /// Create a thread page of thread [tid] or of post [pid].
  const TsdmThreadPage({
    this.tid,
    this.pid,
    this.onlyVisibleUid,
    this.reverseOrder,
    this.exactOrder,
    this.client,
    this.repository,
    super.key,
  }) : assert(tid != null || pid != null);

  /// Thread id.
  final String? tid;

  /// Post id, used when the thread is opened through a post link.
  final String? pid;

  /// Uid of the only visible author.
  final String? onlyVisibleUid;

  /// Whether the posts are shown in reverse order.
  final bool? reverseOrder;

  /// Exact order type.
  final int? exactOrder;

  /// Injected transport, a new one is created when omitted.
  final TsdmHttpClient? client;

  /// Injected repository, built from [client] when omitted.
  final TsdmThreadRepository? repository;

  @override
  State<TsdmThreadPage> createState() => TsdmThreadPageState();
}
