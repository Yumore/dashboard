import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:flutter/material.dart';

/// Favourite toggle, the FlutterCinematic replacement for the source's
/// `FavoriteButton` + `ScopedModelDescendant<AppModel>`. Rebuilds on every
/// store notification so the icon follows `isFavorite`.
class CinematicFavoriteButton extends StatefulWidget {
  const CinematicFavoriteButton({
    required this.store,
    required this.item,
    this.color = Colors.white,
    super.key,
  });

  final CinematicFavoritesStore store;
  final CinematicMediaItem item;
  final Color color;

  @override
  State<CinematicFavoriteButton> createState() =>
      _CinematicFavoriteButtonState();
}

class _CinematicFavoriteButtonState extends State<CinematicFavoriteButton> {
  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onChanged);
    widget.store.load();
  }

  @override
  void dispose() {
    widget.store.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = widget.store.isFavorite(widget.item);
    return IconButton(
      onPressed: () => widget.store.toggle(widget.item),
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      color: isFavorite
          ? Theme.of(context).colorScheme.secondary
          : widget.color,
    );
  }
}
