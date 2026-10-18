import 'package:dashboard/features/movie/fluttermovies/fluttermovies_exception.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_json.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';

/// 列表信封：{code, msg, page, pagecount, limit, total, list}。
class FlutterMoviesListResult {
  const FlutterMoviesListResult({
    this.items = const <FlutterMoviesListItem>[],
    this.page = 0,
    this.pageCount = 0,
    this.total = 0,
    this.limit = 0,
    this.message = '',
  });

  factory FlutterMoviesListResult.fromJson(Map<String, dynamic> json) {
    final rows = json['list'];
    if (rows is! List) {
      final message = FlutterMoviesJson.asString(json['msg']).trim();
      throw FlutterMoviesException(
        message.isEmpty ? '影视频道列表数据格式无法解析' : message,
      );
    }
    return FlutterMoviesListResult(
      items: rows
          .whereType<Map>()
          .map(
            (row) =>
                FlutterMoviesListItem.fromJson(FlutterMoviesJson.asMap(row)),
          )
          .toList(growable: false),
      page: FlutterMoviesJson.asInt(json['page']),
      pageCount: FlutterMoviesJson.asInt(json['pagecount']),
      total: FlutterMoviesJson.asInt(json['total']),
      limit: FlutterMoviesJson.asInt(json['limit']),
      message: FlutterMoviesJson.asString(json['msg']),
    );
  }

  final List<FlutterMoviesListItem> items;
  final int page;
  final int pageCount;
  final int total;
  final int limit;
  final String message;

  bool get isEmpty => items.isEmpty;

  /// 源站用 pagecount 表示总页数；为 0 时不再翻页。
  bool get hasMore => pageCount > 0 && page < pageCount;
}
