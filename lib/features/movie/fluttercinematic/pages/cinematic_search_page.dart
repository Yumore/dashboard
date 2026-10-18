import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_search_page_state.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/pages/search_page.dart`.
///
/// The source used `flutter_search_bar` (`SearchBar` + `SearchBarController`)
/// with a 400ms debounce; that package is not a host dependency, so the same
/// behaviour is hand-written with a `TextField`, a 400ms `Timer` and a request
/// generation counter that discards stale responses.
class CinematicSearchPage extends StatefulWidget {
  const CinematicSearchPage({
    this.api,
    this.store,
    this.initialQuery = '',
    super.key,
  });

  final CinematicApi? api;
  final CinematicFavoritesStore? store;
  final String initialQuery;

  @override
  State<CinematicSearchPage> createState() => CinematicSearchPageState();
}
