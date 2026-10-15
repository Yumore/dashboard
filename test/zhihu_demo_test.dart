import 'package:dashboard/features/reading/reading_module_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_article.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_demo_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_my_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Zhihu demo keeps the four article and five hot-question samples', () {
    expect(articleList, hasLength(4));
    expect(questionList, hasLength(5));
    expect(articleList.first.user, 'learner');
    expect(questionList.first.order, '01');
    expect(questionList.last.order, '05');
  });

  testWidgets('reading entry opens the five-tab demo and its routes', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ReadingModulePage()));
    await tester.tap(find.text('比乎阅读演示'));
    await tester.pumpAndSettle();
    expect(find.text('关注'), findsWidgets);
    expect(find.text('推荐'), findsWidgets);
    expect(find.text('热榜'), findsWidgets);

    await tester.tap(find.text('热榜'));
    await tester.pumpAndSettle();
    expect(find.text('了不起的新时代，世界竞争中的中国制造'), findsOneWidget);
    await tester.tap(find.text('了不起的新时代，世界竞争中的中国制造'));
    await tester.pumpAndSettle();
    expect(find.text('《三体》里的水滴有可能被制造出来吗?'), findsOneWidget);
    await tester.tap(find.text('游牧由'));
    await tester.pumpAndSettle();
    expect(find.textContaining('回归运动'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search, ask, and local theme toggle remain reachable', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ZhihuDemoPage()));
    await tester.tap(find.text('坚果R1摄像头损坏'));
    await tester.pumpAndSettle();
    expect(find.text('比乎热搜'), findsOneWidget);
    expect(find.text('搜索历史'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('提问'));
    await tester.pumpAndSettle();
    expect(find.text('请输入标题'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '下一步'))
          .onPressed,
      isNull,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('日间模式'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ZhihuMyPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('日间模式'));
    await tester.pumpAndSettle();
    expect(find.text('夜间模式'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
