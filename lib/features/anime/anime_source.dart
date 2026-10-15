import 'package:dashboard/features/anime/anime_episode.dart';
import 'package:dashboard/features/anime/anime_show.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

/// Adapted from AnimeTV's Wcostream API; remote availability is not guaranteed.
class AnimeSource {
  AnimeSource({http.Client? client}) : _client = client ?? http.Client();

  static final Uri base = Uri.parse('https://www.wcostream.net/');
  final http.Client _client;

  Future<List<AnimeEpisode>> recent() async {
    final document = html.parse(await _get(base));
    return document
        .querySelectorAll('ul.items > li')
        .map((item) {
          final link = item.querySelector('a[href]');
          final title =
              item.querySelector('.title')?.text.trim() ?? item.text.trim();
          final cover = item.querySelector('img')?.attributes['src'];
          return link == null
              ? null
              : AnimeEpisode(
                  title: title,
                  url: _resolve(link.attributes['href']),
                  cover: cover == null ? null : _resolve(cover),
                );
        })
        .whereType<AnimeEpisode>()
        .toList();
  }

  Future<List<AnimeShow>> catalogue(String path) async {
    final document = html.parse(await _get(base.resolve(path)));
    return document
        .querySelectorAll('div.ddmcc a[href]')
        .map((item) {
          return AnimeShow(
            title: item.text.trim(),
            url: _resolve(item.attributes['href']),
          );
        })
        .where((item) => item.title.isNotEmpty)
        .toList();
  }

  Future<List<AnimeShow>> search(String query) async {
    final response = await _client
        .post(
          base.resolve('/search'),
          headers: {'content-type': 'application/x-www-form-urlencoded'},
          body: {'catara': query, 'konuara': 'series'},
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('搜索失败：HTTP ${response.statusCode}');
    }
    final document = html.parse(response.body);
    return document
        .querySelectorAll('div.iccerceve')
        .map((item) {
          final link = item.querySelector('a[href]');
          if (link == null) return null;
          final image = item.querySelector('img')?.attributes['src'];
          return AnimeShow(
            title: link.text.trim(),
            url: _resolve(link.attributes['href']),
            image: image == null ? null : _resolve(image),
          );
        })
        .whereType<AnimeShow>()
        .where((item) => item.title.isNotEmpty)
        .toList();
  }

  Future<AnimeShow> details(AnimeShow show) async {
    final document = html.parse(await _get(show.url));
    final image = document
        .querySelector('div#cat-img-desc img')
        ?.attributes['src'];
    return AnimeShow(
      title: document.querySelector('td > h2')?.text.trim() ?? show.title,
      url: show.url,
      image: image == null ? show.image : _resolve(image),
      description: document.querySelector('.iltext')?.text.trim() ?? '',
      genres: document
          .querySelectorAll('div#cat-genre a')
          .map((e) => e.text.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      episodes: document.querySelectorAll('div#catlist-listview a[href]').map((
        e,
      ) {
        return AnimeEpisode(
          title: e.text.trim(),
          url: _resolve(e.attributes['href']),
        );
      }).toList(),
    );
  }

  Future<String> _get(Uri uri) async {
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('请求失败：HTTP ${response.statusCode}');
    }
    return response.body;
  }

  Uri _resolve(String? value) => base.resolve(value ?? '');

  void dispose() => _client.close();
}
