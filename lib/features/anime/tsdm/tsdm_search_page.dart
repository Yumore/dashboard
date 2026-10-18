import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_search_page_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_search_repository.dart';
import 'package:flutter/material.dart';

/// Search page of the tsdm forum.
///
/// Ported from `tsdm_client/lib/features/search/view/search_page.dart`: the
/// source searches through the `Kahrpba:search` plugin of forum.php with a
/// keyword, a forum id and an author uid.
class TsdmSearchPage extends StatefulWidget {
  /// Create a search page.
  const TsdmSearchPage({
    this.initialKeyword,
    this.fid = '0',
    this.uid = '0',
    this.client,
    this.repository,
    super.key,
  });

  /// Keyword the page is opened with.
  final String? initialKeyword;

  /// Forum id to search in, `0` searches all forums.
  final String fid;

  /// Author uid to search, `0` searches all authors.
  final String uid;

  /// Injected transport, a new one is created when omitted.
  final TsdmHttpClient? client;

  /// Injected repository, built from [client] when omitted.
  final TsdmSearchRepository? repository;

  @override
  State<TsdmSearchPage> createState() => TsdmSearchPageState();
}
