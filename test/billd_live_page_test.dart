import 'package:dashboard/features/live/billd_live_page.dart';
import 'package:dashboard/features/live/billd_live_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Billd page shows server empty state and original tabs', (
    tester,
  ) async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'code': 200,
              'data': {'rows': <Object>[]},
            },
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BilldLivePage(repository: BilldLiveRepository(dio: dio)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂无正在直播的房间'), findsOneWidget);
    await tester.tap(find.text('排行'));
    await tester.pumpAndSettle();
    expect(find.text('暂无排行内容'), findsOneWidget);
    await tester.tap(find.text('分区'));
    await tester.pumpAndSettle();
    expect(find.text('暂无分区内容'), findsOneWidget);
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('暂无我的内容'), findsOneWidget);
  });
}
