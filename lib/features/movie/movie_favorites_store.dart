import 'dart:convert';

import 'package:dashboard/features/movie/movie_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieFavoritesStore {
  static const _key = 'content_movie_favorites';

  Future<List<MovieItem>> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map(
          (entry) => MovieItem(
            id: int.tryParse('${entry['id']}') ?? 0,
            title: '${entry['title'] ?? ''}',
            poster: Uri.tryParse('${entry['poster'] ?? ''}'),
            description: '${entry['description'] ?? ''}',
            source: Uri.tryParse('${entry['source'] ?? ''}'),
            category: '${entry['category'] ?? ''}',
            serviceEndpoint: entry['serviceEndpoint'] == null
                ? null
                : Uri.tryParse('${entry['serviceEndpoint']}'),
          ),
        )
        .toList();
  }

  Future<void> toggle(MovieItem item) async {
    final current = [...await load()];
    final exists = current.any((saved) => _matches(saved, item));
    current.removeWhere((saved) => _matches(saved, item));
    if (!exists) current.add(item);
    final encoded = current
        .map(
          (saved) => {
            'id': saved.id,
            'title': saved.title,
            'poster': saved.poster?.toString(),
            'description': saved.description,
            'source': saved.source?.toString(),
            'category': saved.category,
            'serviceEndpoint': saved.serviceEndpoint?.toString(),
          },
        )
        .toList();
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(encoded),
    );
  }

  bool _matches(MovieItem saved, MovieItem item) =>
      saved.id == item.id &&
      saved.title == item.title &&
      (saved.serviceEndpoint == null ||
          item.serviceEndpoint == null ||
          saved.serviceEndpoint == item.serviceEndpoint);
}
