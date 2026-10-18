import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_page_state.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_feed_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_feed_page_state.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_follow_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_follow_page_state.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_message_detail_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_profile_detail_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_profile_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_sample_video.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_video_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FlutterTiktokDemoPageState _demoState(WidgetTester tester) => tester
    .state<FlutterTiktokDemoPageState>(find.byType(FlutterTiktokDemoPage));

Future<void> _pumpDemo(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: FlutterTiktokDemoPage()));
  await tester.pumpAndSettle();
}

void main() {
  group('ported mock data', () {
    test('the 9 sample entries match the source list and order', () {
      expect(FlutterTiktokSampleVideo.fileNames, <String>[
        'test-video-10.MP4',
        'test-video-6.mp4',
        'test-video-9.MP4',
        'test-video-8.MP4',
        'test-video-7.MP4',
        'test-video-1.mp4',
        'test-video-2.mp4',
        'test-video-3.mp4',
        'test-video-4.mp4',
      ]);
      expect(FlutterTiktokSampleVideo.fileNames, hasLength(9));
    });

    test('fetchVideo builds the source URLs, images and descriptions', () {
      final List<FlutterTiktokSampleVideo> videos =
          FlutterTiktokSampleVideo.fetchVideo();
      expect(videos, hasLength(9));
      for (int i = 0; i < videos.length; i++) {
        final String name = FlutterTiktokSampleVideo.fileNames[i];
        expect(videos[i].desc, name);
        expect(videos[i].image, '');
        expect(videos[i].url, 'https://static.ybhospital.net/$name');
        expect(
          videos[i].toString(),
          'image:\nvideo:https://static.ybhospital.net/$name',
        );
      }
      expect(
        videos.map((FlutterTiktokSampleVideo video) => video.url).toList(),
        <String>[
          'https://static.ybhospital.net/test-video-10.MP4',
          'https://static.ybhospital.net/test-video-6.mp4',
          'https://static.ybhospital.net/test-video-9.MP4',
          'https://static.ybhospital.net/test-video-8.MP4',
          'https://static.ybhospital.net/test-video-7.MP4',
          'https://static.ybhospital.net/test-video-1.mp4',
          'https://static.ybhospital.net/test-video-2.mp4',
          'https://static.ybhospital.net/test-video-3.mp4',
          'https://static.ybhospital.net/test-video-4.mp4',
        ],
      );
    });

    test('the feed overlay keeps the source author, copy and counts', () {
      expect(FlutterTiktokDemoConfig.feedAuthor, '@朱二旦的枯燥生活');
      expect(
        FlutterTiktokDemoConfig.feedDescription,
        '#原创 有钱人的生活就是这么朴实无华，且枯燥 #短视频',
      );
      expect(FlutterTiktokDemoConfig.feedMusic, '朱二旦的枯燥生活创作的原声');
      expect(FlutterTiktokDemoConfig.favoriteCount, '1.0w');
      expect(FlutterTiktokDemoConfig.commentCount, '4213');
      expect(FlutterTiktokDemoConfig.shareCount, '346');
      expect(FlutterTiktokDemoConfig.commentSheetTitle, '128条评论');
      expect(FlutterTiktokDemoConfig.commentAuthor, '是假用户哟');
      expect(FlutterTiktokDemoConfig.commentText, '这是一条模拟评论，主播666啊。');
      expect(FlutterTiktokDemoConfig.commentLikeCount, '54');
      expect(FlutterTiktokDemoConfig.commentRowCount, 10);
    });
  });

  group('home feed', () {
    testWidgets('renders the source video overlay', (tester) async {
      await _pumpDemo(tester);
      expect(find.byType(FlutterTiktokFeedPage), findsOneWidget);
      expect(find.text('@朱二旦的枯燥生活'), findsWidgets);
      expect(find.text('test-video-10.MP4'), findsWidgets);
      expect(find.text('朱二旦的枯燥生活创作的原声'), findsWidgets);
      expect(find.text('1.0w'), findsWidgets);
      expect(find.text('4213'), findsWidgets);
      expect(find.text('346'), findsWidgets);
      expect(_demoState(tester).favorites, isEmpty);
    });

    testWidgets('swipes vertically through all 9 samples in order', (
      tester,
    ) async {
      await _pumpDemo(tester);
      final FlutterTiktokFeedPageState feed = tester
          .state<FlutterTiktokFeedPageState>(
            find.byType(FlutterTiktokFeedPage),
          );
      expect(feed.videos, hasLength(9));
      expect(feed.currentIndex, 0);
      expect(feed.videos[0].desc, 'test-video-10.MP4');

      await tester.drag(
        find.byKey(FlutterTiktokFeedPage.pageViewKey),
        const Offset(0, -1400),
      );
      await tester.pumpAndSettle();
      expect(feed.currentIndex, 1);
      expect(feed.videos[1].desc, 'test-video-6.mp4');

      await tester.drag(
        find.byKey(FlutterTiktokFeedPage.pageViewKey),
        const Offset(0, -1400),
      );
      await tester.pumpAndSettle();
      expect(feed.currentIndex, 2);
      expect(feed.videos[2].desc, 'test-video-9.MP4');

      await tester.drag(
        find.byKey(FlutterTiktokFeedPage.pageViewKey),
        const Offset(0, 1400),
      );
      await tester.pumpAndSettle();
      expect(feed.currentIndex, 1);
    });

    testWidgets('favorite toggles and double tap only ever likes', (
      tester,
    ) async {
      await _pumpDemo(tester);
      final FlutterTiktokDemoPageState demo = _demoState(tester);
      const String sampleId = 'test-video-10.MP4';

      await tester.tap(
        find.byKey(const Key('fluttertiktok_favorite_$sampleId')),
      );
      await tester.pump();
      expect(demo.favorites[0], isTrue);
      Icon heart = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('fluttertiktok_favorite_$sampleId')),
          matching: find.byIcon(Icons.favorite),
        ),
      );
      expect(heart.color, FlutterTiktokPalette.red);

      await tester.tap(
        find.byKey(const Key('fluttertiktok_favorite_$sampleId')),
      );
      await tester.pump();
      expect(demo.favorites[0], isFalse);
      heart = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('fluttertiktok_favorite_$sampleId')),
          matching: find.byIcon(Icons.favorite),
        ),
      );
      expect(heart.color, FlutterTiktokPalette.white);

      final Finder gesture = find.byKey(
        FlutterTiktokVideoPage.gestureKey(sampleId),
      );
      await tester.tap(gesture);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(gesture);
      await tester.pumpAndSettle();
      expect(demo.favorites[0], isTrue);
    });

    testWidgets('comment button opens the ported comment sheet', (
      tester,
    ) async {
      await _pumpDemo(tester);
      await tester.tap(
        find.byKey(const Key('fluttertiktok_comment_test-video-10.MP4')),
      );
      await tester.pumpAndSettle();
      expect(find.text('128条评论'), findsOneWidget);
      expect(find.text('是假用户哟'), findsWidgets);
      expect(find.text('这是一条模拟评论，主播666啊。'), findsWidgets);
      expect(find.text('54'), findsWidgets);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('128条评论'), findsNothing);
    });

    testWidgets('share and tv controls stay inert', (tester) async {
      await _pumpDemo(tester);
      await tester.tap(
        find.byKey(const Key('fluttertiktok_share_test-video-10.MP4')),
      );
      await tester.pump();
      expect(find.text('128条评论'), findsNothing);
      expect(find.byType(FlutterTiktokDemoPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.tv));
      await tester.pump();
      expect(find.byType(FlutterTiktokDemoPage), findsOneWidget);
      expect(find.text('搜索内容'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('follow feed', () {
    testWidgets('has 10 source rows and toggles the per-row like', (
      tester,
    ) async {
      await _pumpDemo(tester);
      await tester.tap(find.byKey(const Key('fluttertiktok_tab_follow')));
      await tester.pumpAndSettle();
      expect(find.byType(FlutterTiktokFollowPage), findsOneWidget);
      expect(find.text('朱二蛋的枯燥生活'), findsWidgets);
      expect(find.text('10-9'), findsWidgets);
      expect(FlutterTiktokFollowPage.itemCount, 10);

      final FlutterTiktokFollowPageState follow = tester
          .state<FlutterTiktokFollowPageState>(
            find.byType(FlutterTiktokFollowPage),
          );
      expect(follow.favorites, isEmpty);

      await tester.tap(find.byKey(const Key('fluttertiktok_follow_like_0')));
      await tester.pump();
      expect(follow.favorites[0], isTrue);
      final Icon heart = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('fluttertiktok_follow_like_0')),
          matching: find.byIcon(Icons.favorite),
        ),
      );
      expect(heart.color, FlutterTiktokPalette.red);

      await tester.tap(find.byKey(const Key('fluttertiktok_follow_share_0')));
      await tester.pump();
      expect(find.text('128条评论'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('fluttertiktok_follow_comment_0')));
      await tester.pumpAndSettle();
      expect(find.text('128条评论'), findsOneWidget);
    });
  });

  group('messages', () {
    testWidgets('lists the source sections and opens 20-row detail lists', (
      tester,
    ) async {
      await _pumpDemo(tester);
      await tester.tap(find.byKey(const Key('fluttertiktok_tab_msg')));
      await tester.pumpAndSettle();
      expect(find.text('系统'), findsNWidgets(2));
      expect(find.text('私信'), findsOneWidget);
      expect(find.text('商务洽谈'), findsOneWidget);
      expect(find.text('您收到了3个商务洽谈申请'), findsOneWidget);
      expect(find.text('12条未读的系统消息'), findsOneWidget);
      expect(find.text('98条未读通知'), findsOneWidget);
      expect(find.text('预留轮播图'), findsOneWidget);
      expect(find.text('10-12'), findsWidgets);

      await tester.tap(find.byKey(const Key('fluttertiktok_message_entry_粉丝')));
      await tester.pumpAndSettle();
      expect(find.text('粉丝'), findsOneWidget);
      expect(find.text('你的粉丝'), findsWidgets);
      expect(find.text('我是你的粉丝'), findsWidgets);
      expect(FlutterTiktokMessageDetailPage.rowCount, 20);

      await tester.tap(find.byKey(const Key('fluttertiktok_app_bar_back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('fluttertiktok_message_entry_@')));
      await tester.pumpAndSettle();
      expect(find.text('Ta提到了你'), findsWidgets);
    });
  });

  group('search drawer', () {
    testWidgets('opens with the source hot-search list and closes', (
      tester,
    ) async {
      await _pumpDemo(tester);
      await tester.tap(find.byKey(const Key('fluttertiktok_header_search')));
      await tester.pumpAndSettle();
      expect(find.text('搜索内容'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('搜索热点'), findsNWidgets(5));
      expect(find.text('全部搜索记录'), findsOneWidget);

      await tester.tap(find.byKey(const Key('fluttertiktok_search_hot_0')));
      await tester.pump();
      expect(find.text('搜索内容'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('fluttertiktok_search_cancel')));
      await tester.pumpAndSettle();
      expect(find.text('搜索内容'), findsNothing);
      expect(find.text('@朱二旦的枯燥生活'), findsWidgets);
    });
  });

  group('profile', () {
    testWidgets('self tab shows the source mock profile with inert controls', (
      tester,
    ) async {
      await _pumpDemo(tester);
      await tester.tap(find.byKey(const Key('fluttertiktok_tab_me')));
      await tester.pumpAndSettle();
      expect(find.text('@用户名'), findsOneWidget);
      expect(find.text('朴实无华，且枯燥'), findsOneWidget);
      expect(find.text('幽默'), findsOneWidget);
      expect(find.text('机智'), findsOneWidget);
      expect(find.text('枯燥'), findsOneWidget);
      expect(find.text('狮子座'), findsOneWidget);
      expect(find.text('356'), findsOneWidget);
      expect(find.text('145万'), findsOneWidget);
      expect(find.text('1423万'), findsOneWidget);
      expect(find.text('钱包'), findsOneWidget);

      await tester.tap(find.byKey(FlutterTiktokProfilePage.actionKey));
      await tester.pump();
      expect(find.text('钱包'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byType(FlutterTiktokProfileDetailPage), findsNothing);

      await tester.tap(find.byKey(const Key('fluttertiktok_profile_tab_1')));
      await tester.pump();
      expect(find.text('作品'), findsWidgets);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.byKey(const Key('fluttertiktok_profile_tile_23')),
        400,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('fluttertiktok_profile_scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(
        find.byKey(const Key('fluttertiktok_profile_tile_23')),
        findsOneWidget,
      );
      expect(FlutterTiktokDemoConfig.profileVideoTileCount, 24);
    });

    testWidgets('more button opens and closes the profile detail page', (
      tester,
    ) async {
      await _pumpDemo(tester);
      await tester.tap(find.byKey(const Key('fluttertiktok_tab_me')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(FlutterTiktokProfilePage.moreKey));
      await tester.pumpAndSettle();
      expect(find.byType(FlutterTiktokProfileDetailPage), findsOneWidget);
      expect(find.text('用户'), findsOneWidget);
      expect(find.text('个人信息'), findsOneWidget);
      expect(find.text('修改'), findsOneWidget);
      expect(find.text('昵称'), findsOneWidget);
      expect(find.text('朱二蛋的枯燥生活'), findsOneWidget);
      expect(find.text('186****7767'), findsOneWidget);
      expect(find.text('深圳市南山区南海大道'), findsOneWidget);
      expect(find.text('男'), findsOneWidget);
      expect(find.text('总裁'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('fluttertiktok_profile_detail_row_0')),
      );
      await tester.pump();
      expect(find.text('个人信息'), findsOneWidget);

      await tester.tap(find.byKey(const Key('fluttertiktok_app_bar_back')));
      await tester.pumpAndSettle();
      expect(find.byType(FlutterTiktokProfileDetailPage), findsNothing);
    });

    testWidgets('feed avatar draws the other-user profile drawer', (
      tester,
    ) async {
      await _pumpDemo(tester);
      await tester.tap(
        find.byKey(const Key('fluttertiktok_avatar_test-video-10.MP4')),
      );
      await tester.pumpAndSettle();
      expect(find.text('@用户名'), findsOneWidget);
      expect(find.text('关注'), findsWidgets);
      await tester.tap(find.byKey(FlutterTiktokProfilePage.backKey));
      await tester.pumpAndSettle();
      expect(find.text('@朱二旦的枯燥生活'), findsWidgets);
    });
  });

  group('page shell', () {
    testWidgets('horizontal swipes reach the search and profile drawers', (
      tester,
    ) async {
      await _pumpDemo(tester);
      final Finder root = find.byKey(
        FlutterTiktokDemoPageState.rootPageViewKey,
      );

      await tester.drag(root, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(find.text('搜索内容'), findsOneWidget);

      await tester.drag(root, const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('@朱二旦的枯燥生活'), findsWidgets);

      await tester.drag(root, const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('@用户名'), findsOneWidget);
      expect(find.text('关注'), findsWidgets);
    });
  });

  group('camera', () {
    testWidgets('opens the fake camera and keeps its dead controls dead', (
      tester,
    ) async {
      await _pumpDemo(tester);
      await tester.tap(find.byKey(const Key('fluttertiktok_tab_add')));
      await tester.pumpAndSettle();
      expect(find.text('翻转'), findsOneWidget);
      expect(find.text('速度'), findsOneWidget);
      expect(find.text('滤镜'), findsOneWidget);
      expect(find.text('美化'), findsOneWidget);
      expect(find.text('计时关'), findsOneWidget);
      expect(find.text('选择音乐'), findsOneWidget);
      expect(find.text('道具'), findsOneWidget);
      expect(find.text('上传'), findsOneWidget);

      await tester.tap(find.byKey(const Key('fluttertiktok_camera_tool_0')));
      await tester.tap(find.byKey(const Key('fluttertiktok_camera_capture')));
      await tester.tap(find.byKey(const Key('fluttertiktok_camera_prop')));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('fluttertiktok_camera_close')));
      await tester.pumpAndSettle();
      expect(find.text('翻转'), findsNothing);
      expect(find.byType(FlutterTiktokDemoPage), findsOneWidget);
    });
  });
}
