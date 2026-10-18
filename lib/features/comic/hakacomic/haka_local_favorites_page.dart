import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_favorite_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_local_favorites_page_state.dart';

/// Local favourites tab: folders plus their saved comic documents.
///
/// Body-only: the module page owns the scaffold and tab bar.
class HakaLocalFavoritesPage extends StatefulWidget {
  const HakaLocalFavoritesPage({
    super.key,
    required this.favoriteStore,
    required this.onOpenComic,
  });

  final HakaFavoriteStore favoriteStore;

  final void Function(String comicId) onOpenComic;

  @override
  State<HakaLocalFavoritesPage> createState() => HakaLocalFavoritesPageState();
}
