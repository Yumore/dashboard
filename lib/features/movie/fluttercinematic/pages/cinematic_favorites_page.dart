import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_favorites_page_state.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/pages/favorites_page.dart`: one tab per media type,
/// fed by the same store the home/detail pages toggle. The source stored
/// `MediaItem.toJson()` strings in `SharedPreferences`; this page only reads
/// that state back through [CinematicFavoritesStore].
class CinematicFavoritesPage extends StatefulWidget {
  const CinematicFavoritesPage({required this.store, super.key});

  final CinematicFavoritesStore store;

  @override
  State<CinematicFavoritesPage> createState() => CinematicFavoritesPageState();
}
