import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_media_detail_page_state.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/pages/media_detail_page.dart` with its
/// `MovieDetailPage` / `ShowDetailPage` variants folded into one widget keyed
/// by [type] (`movie` | `tv`), exactly how the source `ApiClient` is keyed.
class CinematicMediaDetailPage extends StatefulWidget {
  const CinematicMediaDetailPage({
    required this.id,
    required this.type,
    required this.title,
    this.api,
    this.store,
    super.key,
  });

  final int id;

  /// `movie` or `tv`.
  final String type;

  /// Used for the app bar until the detail payload arrives.
  final String title;

  final CinematicApi? api;
  final CinematicFavoritesStore? store;

  @override
  State<CinematicMediaDetailPage> createState() =>
      CinematicMediaDetailPageState();
}
