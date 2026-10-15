import 'package:dashboard/features/live/billd_live_room.dart';
import 'package:dio/dio.dart';

/// Migrates billd-live-flutter's /live/list request into the host Dio client.
class BilldLiveRepository {
  BilldLiveRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://live-api.hsslive.cn',
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  Future<List<BilldLiveRoom>> load({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get<dynamic>(
      '/live/list',
      queryParameters: {'nowPage': page, 'pageSize': pageSize},
    );
    final envelope = response.data;
    if (envelope is! Map || envelope['code'] != 200) {
      throw FormatException(
        '直播列表请求失败：${envelope is Map ? envelope['msg'] : response.statusCode}',
      );
    }
    final data = envelope['data'];
    if (data is! Map || data['rows'] is! List) {
      throw const FormatException('直播列表格式错误');
    }
    return (data['rows'] as List)
        .whereType<Map>()
        .map(
          (row) => BilldLiveRoom.fromJson(
            row.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }

  void dispose() => _dio.close();
}
