import 'dart:convert';

import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence + state for FlutterCinematic favourites.
///
/// Replaces the source `scoped_model` (`lib/scoped_models/app_model.dart`),
/// which is not a host dependency. It keeps the source's storage contract:
/// a `List<String>` of `MediaItem.toJson()` payloads under
/// `media_favorites_key`, with `type` written as `1` for movies and `0` for
/// shows.
///
/// The source also stored the dark/light theme index under `theme_prefs_key`;
/// the host already owns theming, so that half is deliberately not ported.
class CinematicFavoritesStore extends ChangeNotifier {
  CinematicFavoritesStore({Future<SharedPreferences> Function()? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance;

  /// The source key (`AppModel._FAVORITES_KEY`).
  static const String prefsKey = 'media_favorites_key';

  final Future<SharedPreferences> Function() _preferences;
  final List<CinematicMediaItem> _favorites = <CinematicMediaItem>[];
  Future<void>? _loading;

  List<CinematicMediaItem> get favorites => List.unmodifiable(_favorites);

  List<CinematicMediaItem> get movieFavorites => _favorites
      .where((item) => item.type == CinematicMediaType.movie)
      .toList();

  List<CinematicMediaItem> get showFavorites =>
      _favorites.where((item) => item.type == CinematicMediaType.show).toList();

  Future<void> load() => _loading ??= _restore();

  Future<void> _restore() async {
    final prefs = await _preferences();
    final raw = prefs.getStringList(prefsKey) ?? const <String>[];
    _favorites
      ..clear()
      ..addAll(
        raw
            .map(_decode)
            .whereType<CinematicMediaItem>()
            .toList(growable: false),
      );
    notifyListeners();
  }

  CinematicMediaItem? _decode(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        return CinematicMediaItem.fromPrefsJson(
          decoded.map((key, item) => MapEntry('$key', item)),
        );
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  bool isFavorite(CinematicMediaItem item) =>
      _favorites.any((saved) => saved.id == item.id);

  Future<void> toggle(CinematicMediaItem item) async {
    await load();
    if (isFavorite(item)) {
      _favorites.removeWhere((saved) => saved.id == item.id);
    } else {
      _favorites.add(item);
    }
    notifyListeners();
    final prefs = await _preferences();
    await prefs.setStringList(
      prefsKey,
      _favorites.map((saved) => jsonEncode(saved.toJson())).toList(),
    );
  }
}
