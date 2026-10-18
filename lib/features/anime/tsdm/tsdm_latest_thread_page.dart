import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_latest_thread_page_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_latest_thread_repository.dart';
import 'package:flutter/material.dart';

/// Latest thread page: the forum thread stream of `forum.php`.
///
/// Ported from `tsdm_client/lib/features/latest_thread/view/latest_thread_page.dart`.
class TsdmLatestThreadPage extends StatefulWidget {
  /// Create a latest thread page.
  const TsdmLatestThreadPage({
    required this.url,
    this.title,
    this.client,
    this.repository,
    super.key,
  });

  /// Url of the first page, usually [TsdmApiUrls.homePage].
  final String url;

  /// Page title.
  final String? title;

  /// Injected transport, a new one is created when omitted.
  final TsdmHttpClient? client;

  /// Injected repository, built from [client] when omitted.
  final TsdmLatestThreadRepository? repository;

  @override
  State<TsdmLatestThreadPage> createState() => TsdmLatestThreadPageState();
}
