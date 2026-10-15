import 'dart:convert';

import 'package:dashboard/features/anime/anime_episode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimeWatchStore {
  static const _key = 'content.anime.watched';

  Future<Map<String, dynamic>> _load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return {};
    final value = jsonDecode(raw);
    return value is Map<String, dynamic> ? value : {};
  }

  Future<AnimeEpisode?> last() async {
    final value = (await _load())['last'];
    if (value is! Map) return null;
    final url = Uri.tryParse('${value['url'] ?? ''}');
    if (url == null || !url.hasScheme) return null;
    return AnimeEpisode(title: '${value['title'] ?? ''}', url: url);
  }

  Future<Set<String>> watchedUrls() async {
    final value = (await _load())['urls'];
    return value is List ? value.whereType<String>().toSet() : {};
  }

  Future<void> record(AnimeEpisode episode) async {
    final value = await _load();
    final urls = value['urls'];
    final watched = urls is List
        ? urls.whereType<String>().toSet()
        : <String>{};
    watched.add(episode.url.toString());
    value['urls'] = watched.toList();
    value['last'] = {'url': episode.url.toString(), 'title': episode.title};
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(value),
    );
  }
}
