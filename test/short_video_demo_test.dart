import 'package:dashboard/features/short_video/short_video_clip.dart';
import 'package:dashboard/features/short_video/short_video_demo_page.dart';
import 'package:dashboard/features/short_video/short_video_feed_page.dart';
import 'package:dashboard/features/short_video/short_video_layout_page.dart';
import 'package:dashboard/features/short_video/short_video_like_page.dart';
import 'package:dashboard/features/short_video/short_video_music_title.dart';
import 'package:dashboard/features/movie/movie_module_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('movie entry opens the local short video demo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: MovieModulePage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('本地短视频演示'));
    await tester.pumpAndSettle();
    expect(find.byType(ShortVideoDemoPage), findsOneWidget);
  });

  testWidgets('short video demos open from their own entry', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ShortVideoDemoPage()));
    expect(find.text('双击点赞动画'), findsOneWidget);
    expect(find.text('关注 / 推荐布局'), findsOneWidget);
    expect(find.text('竖向视频列表'), findsOneWidget);
    await tester.tap(find.text('关注 / 推荐布局'));
    await tester.pumpAndSettle();
    expect(find.byType(ShortVideoLayoutPage), findsOneWidget);
    await tester.tap(find.text('关注'));
    await tester.pumpAndSettle();
    expect(find.text('关注'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('双击点赞动画'));
    await tester.pumpAndSettle();
    expect(find.byType(ShortVideoLikePage), findsOneWidget);
  });

  testWidgets('double tap creates a temporary heart', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ShortVideoLikePage()));
    final center = tester.getCenter(find.text('双击屏幕点赞'));
    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(center);
    await tester.pump();
    expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });

  testWidgets('vertical swipes select the second local clip', (tester) async {
    expect(ShortVideoClip.samples.length, 2);
    await tester.pumpWidget(
      MaterialApp(
        home: ShortVideoFeedPage(
          clipBuilder: (clip) => Center(child: Text(clip.video)),
        ),
      ),
    );
    expect(find.textContaining('1.MP4'), findsOneWidget);
    await tester.fling(find.byType(PageView), const Offset(0, -500), 1200);
    await tester.pumpAndSettle();
    expect(find.textContaining('2.mp4'), findsOneWidget);
  });

  testWidgets('music title scrolls and cancels its timers on exit', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: ShortVideoMusicTitle(title: '三根皮带歌曲,哗啦啦啦啦啦啦啦啦啦')),
        ),
      ),
    );
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, 0);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 750));
    expect(scrollable.position.pixels, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 750));
    final endOffset = scrollable.position.pixels;
    await tester.pump(const Duration(milliseconds: 750));
    expect(scrollable.position.pixels, lessThan(endOffset));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });
}
