import 'package:dashboard/features/anime/anime_category.dart';
import 'package:dashboard/features/anime/anime_episode.dart';
import 'package:dashboard/features/anime/anime_favorite_store.dart';
import 'package:dashboard/features/anime/anime_show.dart';
import 'package:dashboard/features/anime/anime_show_details_page.dart';
import 'package:dashboard/features/anime/anime_watch_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'favorites retain metadata and can read the prior host format',
    () async {
      SharedPreferences.setMockInitialValues({
        'content_anime_favorites': ['https://example.com/old\n旧收藏'],
      });
      final store = AnimeFavoriteStore();
      final show = AnimeShow(
        title: '新收藏',
        url: Uri.parse('https://example.com/new'),
        description: '简介',
        image: Uri.parse('https://example.com/cover.jpg'),
      );
      await store.toggle(show);
      final saved = await AnimeFavoriteStore().load();
      expect(saved.length, 2);
      expect(saved.last.image, show.image);
      expect(saved.last.description, '简介');
      await store.toggle(show);
      expect((await store.load()).single.title, '旧收藏');
    },
  );

  test(
    'movies and OVAs are direct episode routes, not series detail routes',
    () {
      expect(
        AnimeCategory.values
            .where((category) => category.directPlayback)
            .map((category) => category.path),
        ['/movie-list', '/ova-list'],
      );
    },
  );

  testWidgets('details show favorite and watched status and reverse episodes', (
    tester,
  ) async {
    final first = AnimeEpisode(
      title: '第一集',
      url: Uri.parse('https://example.com/ep1'),
    );
    final second = AnimeEpisode(
      title: '第二集',
      url: Uri.parse('https://example.com/ep2'),
    );
    final show = AnimeShow(
      title: '番剧',
      url: Uri.parse('https://example.com/show'),
      episodes: [first, second],
    );
    final history = AnimeWatchStore();
    await history.record(first);
    final favorites = AnimeFavoriteStore();
    await tester.pumpWidget(
      MaterialApp(
        home: AnimeShowDetailsPage(
          show: show,
          favorites: favorites,
          history: history,
          onChanged: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('第一集')).dy,
      lessThan(tester.getTopLeft(find.text('第二集')).dy),
    );
    await tester.tap(find.text('倒序排列'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('第一集')).dy,
      greaterThan(tester.getTopLeft(find.text('第二集')).dy),
    );
    await tester.tap(find.byTooltip('收藏动漫'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('取消收藏'), findsOneWidget);
    expect((await favorites.load()).single.url, show.url);
  });
}
