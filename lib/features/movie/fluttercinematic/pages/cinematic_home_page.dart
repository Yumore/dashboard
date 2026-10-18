import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_home_page_state.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/pages/home_page.dart`.
///
/// The source wrapped the app in `ScopedModel<AppModel>` and built one
/// `MediaList` per category from `fetchMovies`/`fetchShows` using the category
/// strings in `lib/util/constants.dart`. This port drops the scoped model in
/// favour of the host's explicit [CinematicFavoritesStore] and keeps all six
/// category tabs. The source's theme toggle and `NavigationDrawer` are not
/// ported: the host owns theming and the app shell (see the Lead snippet).
class CinematicHomePage extends StatefulWidget {
  const CinematicHomePage({this.api, this.store, super.key});

  /// Injectable for tests/embedding; a default `CinematicApi` is created
  /// otherwise.
  final CinematicApi? api;

  /// Injectable favourites store; one is created (and disposed) otherwise.
  final CinematicFavoritesStore? store;

  @override
  State<CinematicHomePage> createState() => CinematicHomePageState();
}
