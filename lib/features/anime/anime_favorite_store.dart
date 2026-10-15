import 'dart:convert';

import 'package:dashboard/features/anime/anime_show.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimeFavoriteStore {
  static const _key = 'content_anime_favorites';
  Future<void> _pending = Future.value();

  Future<List<AnimeShow>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const [])
        .map((entry) {
          if (entry.startsWith('{')) {
            final value = jsonDecode(entry) as Map<String, dynamic>;
            return AnimeShow(
              url: Uri.parse(value['url'] as String),
              title: value['title'] as String,
              description: value['description'] as String? ?? '',
              image: value['image'] == null
                  ? null
                  : Uri.tryParse(value['image'] as String),
            );
          }
          // Read the earlier host format without dropping existing favorites.
          final separator = entry.indexOf('\n');
          if (separator < 0) return null;
          final url = Uri.tryParse(entry.substring(0, separator));
          return url == null
              ? null
              : AnimeShow(url: url, title: entry.substring(separator + 1));
        })
        .whereType<AnimeShow>()
        .toList();
  }

  Future<void> toggle(AnimeShow show) {
    final result = _pending.then((_) => _toggle(show));
    _pending = result.catchError((Object _) {});
    return result;
  }

  Future<void> _toggle(AnimeShow show) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await load();
    final existed = current.any((item) => item.url == show.url);
    current.removeWhere((item) => item.url == show.url);
    if (!existed) {
      current.add(show);
    }
    await prefs.setStringList(
      _key,
      current
          .map(
            (item) => jsonEncode({
              'url': item.url.toString(),
              'title': item.title,
              'description': item.description,
              'image': item.image?.toString(),
            }),
          )
          .toList(),
    );
  }
}
