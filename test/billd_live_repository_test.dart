import 'package:dashboard/features/live/billd_live_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Billd list uses required pagination and parses rooms', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.uri.path, '/live/list');
          expect(options.uri.queryParameters['nowPage'], '1');
          expect(options.uri.queryParameters['pageSize'], '20');
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'code': 200,
                'data': {
                  'rows': [
                    {'id': 11, 'title': '直播间'},
                  ],
                },
              },
            ),
          );
        },
      ),
    );
    final repository = BilldLiveRepository(dio: dio);
    final rooms = await repository.load();
    expect(rooms.single.id, '11');
    expect(rooms.single.title, '直播间');
    repository.dispose();
  });
}
