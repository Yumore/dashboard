import 'dart:convert';

import 'package:dashboard/features/anime/anime_show.dart';
import 'package:dashboard/features/anime/anime_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('AnimeTV source parses recent, catalogue, search and detail HTML', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/') {
        return http.Response.bytes(
          utf8.encode(
            '''<ul class="items"><li><a href="/ep-1"><img src="//cdn.example/1.jpg"></a><span class="title">第一集</span></li></ul>''',
          ),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      }
      if (request.url.path == '/subbed-anime-list') {
        return http.Response.bytes(
          utf8.encode('''<div class="ddmcc"><a href="/show-1">番剧一</a></div>'''),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      }
      if (request.url.path == '/search') {
        return http.Response.bytes(
          utf8.encode(
            '''<div class="iccerceve"><a href="/show-1">番剧一</a><img src="/1.jpg"></div>''',
          ),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      }
      return http.Response.bytes(
        utf8.encode(
          '''<table><tr><td><h2>番剧一</h2></td></tr></table><div id="cat-genre"><a>冒险</a></div><div id="catlist-listview"><a href="/ep-1">第一集</a></div>''',
        ),
        200,
        headers: {'content-type': 'text/html; charset=utf-8'},
      );
    });
    final source = AnimeSource(client: client);
    expect((await source.recent()).single.title, '第一集');
    final shows = await source.catalogue('/subbed-anime-list');
    expect(shows.single.title, '番剧一');
    expect((await source.search('番剧')).single.title, '番剧一');
    final details = await source.details(
      AnimeShow(title: '番剧一', url: shows.single.url),
    );
    expect(details.genres, ['冒险']);
    expect(details.episodes.single.url.path, '/ep-1');
    source.dispose();
  });
}
