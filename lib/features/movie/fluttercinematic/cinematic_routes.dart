import 'package:dashboard/features/movie/fluttercinematic/cinematic_actor.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_search_result.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_tv_season.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_actor_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_media_detail_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_season_detail_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_search_page.dart';
import 'package:flutter/material.dart';

/// Route builders shared by the FlutterCinematic pages, replacing the source's
/// repeated `MaterialPageRoute` literals.
class CinematicRoutes {
  const CinematicRoutes._();

  static Route<void> mediaDetail(CinematicMediaItem item) => MaterialPageRoute(
    builder: (_) => CinematicMediaDetailPage(
      id: item.id,
      type: item.isMovie ? 'movie' : 'tv',
      title: item.title,
    ),
  );

  static Route<void> mediaDetailById({
    required int id,
    required String type,
    required String title,
  }) => MaterialPageRoute(
    builder: (_) => CinematicMediaDetailPage(id: id, type: type, title: title),
  );

  static Route<void> seasonDetail({
    required int showId,
    required CinematicTvSeason season,
    required String showTitle,
  }) => MaterialPageRoute(
    builder: (_) => CinematicSeasonDetailPage(
      showId: showId,
      season: season,
      showTitle: showTitle,
    ),
  );

  static Route<void> actor(CinematicActor actor) => MaterialPageRoute(
    builder: (_) => CinematicActorPage(actorId: actor.id, name: actor.name),
  );

  static Route<void> search({
    CinematicFavoritesStore? store,
    String query = '',
  }) => MaterialPageRoute(
    builder: (_) => CinematicSearchPage(store: store, initialQuery: query),
  );

  static Route<void> searchResult(CinematicSearchResult result) {
    switch (result.mediaType) {
      case 'movie':
        return mediaDetail(result.asMovie);
      case 'tv':
        return mediaDetail(result.asShow);
      case 'person':
        return actor(result.asActor);
      default:
        return MaterialPageRoute(
          builder: (_) => CinematicSearchPage(initialQuery: result.title),
        );
    }
  }
}
