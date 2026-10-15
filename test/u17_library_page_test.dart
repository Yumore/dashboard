import 'package:dashboard/features/comic/u17_library_page.dart';
import 'package:dashboard/features/comic/u17_library_store.dart';
import 'package:dashboard/features/comic/u17_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('pagination, detail favorites and local library are connected', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final pages = <int>[];
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final Object payload;
          if (options.path.endsWith('conditionScreenlists')) {
            final page = options.queryParameters['page'] as int;
            pages.add(page);
            payload = {
              'comics': page == 1
                  ? [
                      {'comic_id': 1, 'name': '第一部'},
                    ]
                  : [
                      {'comic_id': 1, 'name': '重复结果'},
                      {'comic_id': 2, 'name': '第二部'},
                    ],
            };
          } else {
            payload = {
              'comic': {
                'comic_id': 2,
                'name': '第二部',
                'author': {'name': '作者甲'},
              },
              'chapter_list': [
                {'chapter_id': '21', 'name': '付费章节', 'has_locked_image': true},
              ],
            };
          }
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': {'stateCode': 1, 'returnData': payload},
              },
            ),
          );
        },
      ),
    );
    final source = U17Source(dio: dio);
    final store = U17LibraryStore();
    await tester.pumpWidget(
      MaterialApp(
        home: U17LibraryPage(source: source, store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('第一部'), findsOneWidget);
    await tester.tap(find.text('加载更多'));
    await tester.pumpAndSettle();
    expect(pages, [1, 2]);
    expect(find.text('第一部'), findsOneWidget);
    expect(find.text('重复结果'), findsNothing);
    await tester.tap(find.text('第二部'));
    await tester.pumpAndSettle();
    expect(find.text('作者：作者甲'), findsOneWidget);
    expect(
      tester.widget<ListTile>(find.widgetWithText(ListTile, '付费章节')).onTap,
      isNull,
    );
    await tester.tap(find.byTooltip('关注漫画'));
    await tester.pumpAndSettle();
    expect((await store.favorites()).single.id, 2);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('关注'));
    await tester.pumpAndSettle();
    expect(find.text('第二部'), findsOneWidget);
    expect(find.text('第一部'), findsNothing);
    source.dispose();
  });
}
