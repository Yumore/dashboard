import 'dart:convert';

import 'package:dashboard/features/anime/anime_episode.dart';
import 'package:dashboard/features/anime/anime_hub_controller.dart';
import 'package:dashboard/features/anime/anime_recent_tab.dart';
import 'package:dashboard/features/anime/anime_show.dart';
import 'package:dashboard/features/anime/anime_source.dart';
import 'package:dashboard/features/chat/chat_module_page.dart';
import 'package:dashboard/features/live/live_module_page.dart';
import 'package:dashboard/features/movie/movie_module_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAnimeSource extends AnimeSource {
  @override
  Future<List<AnimeEpisode>> recent() async => [
    AnimeEpisode(title: '已看', url: Uri.parse('https://example.com/watched')),
    AnimeEpisode(title: '未看', url: Uri.parse('https://example.com/fresh')),
  ];

  @override
  Future<List<AnimeShow>> catalogue(String path) async => const [];
}

void main() {
  testWidgets('movie module reports a persisted invalid endpoint', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'content_movie_endpoint': 'ftp://example.com',
    });
    await tester.pumpWidget(const MaterialApp(home: MovieModulePage()));
    await tester.pumpAndSettle();
    expect(find.text('请输入 HTTP/HTTPS 影视服务地址'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat new-conversation dialog opens and cancels', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: ChatModulePage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('新建会话'));
    await tester.pumpAndSettle();
    expect(find.text('新建本地会话'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('新建本地会话'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('live module rejects a non HTTP subscription address', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: LiveModulePage()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'not-a-url');
    await tester.tap(find.text('加载频道'));
    await tester.pumpAndSettle();
    expect(find.text('请输入 HTTP/HTTPS M3U 或 TXT 订阅地址'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('anime recent tab marks watched episodes', (tester) async {
    SharedPreferences.setMockInitialValues({
      'content.anime.watched': jsonEncode({
        'urls': ['https://example.com/watched'],
      }),
    });
    final controller = AnimeHubController(source: _FakeAnimeSource());
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AnimeRecentTab(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('已看'), findsOneWidget);
    expect(find.text('未看'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}
