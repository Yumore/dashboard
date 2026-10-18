import 'package:dashboard/features/movie/fluttermovies/fluttermovies_category.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_exception.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_json.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_result.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_video_detail.dart';
import 'package:dio/dio.dart';

/// 今日看片（`https://www.jinrikanpian.net/appapi.php`）CMS 客户端。
///
/// 站点自有接口，无需开发者凭据；参数名与源站一致
/// （`ac` / `pt` / `t` / `pg` / `wd` / `h` / `pagesize` / `leve` / `order`）。
/// 源站没有签名或加解密，这里也没有。
class FlutterMoviesApi {
  FlutterMoviesApi({Dio? dio, this.webUrl = defaultWebUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  static const String defaultWebUrl = 'https://www.jinrikanpian.net/';
  static const String vodPath = 'appapi.php/api/vod/';
  static const String allCategoriesPath = 'appapi.php/api/vodCategoryAll';
  static const String parentCategoriesPath = 'appapi.php/api/getPcategory';
  static const String subcategoriesPath =
      'appapi.php/api/getSubcategoryByPcategory';

  static const int homeSliderLeve = 9;
  static const int homeGridLeve = 8;
  static const int categoryPageSize = 10;
  static const int rankingPageSize = 20;

  final Dio _dio;
  final String webUrl;

  /// 列表请求参数，与源站 `getMoviesByCategory` 发出的请求完全一致：
  /// 8 个键永远出现在查询串里，为 null 的键由 dio 编码成「裸键」
  /// （dio 5.x `Transformer.urlEncodeQueryMap`：`if (value == null) return key;`），
  /// 例如 `appapi.php/api/vod/?ac=detail&pt&t=1&pg=1&pagesize=10&order=vod_level`。
  /// 顺序也与源站一致（ac 在 URL 里、其余按声明顺序），便于逐字符比对。
  static Map<String, dynamic> vodQuery({
    int? pt,
    int? t,
    int? pg,
    String? wd,
    int? h,
    int? pagesize,
    int? leve,
    String? order,
  }) => <String, dynamic>{
    'ac': 'detail',
    'pt': pt,
    't': t,
    'pg': pg,
    'wd': wd,
    'h': h,
    'pagesize': pagesize,
    'leve': leve,
    'order': order,
  };

  /// 首页幻灯片：leve=9，默认 5 条。
  Future<FlutterMoviesListResult> homeSliders({
    int leve = homeSliderLeve,
    int pagesize = 5,
  }) => vodList(leve: leve, pagesize: pagesize);

  /// 首页网格：按父类推荐，leve=8，默认 6 条。
  Future<FlutterMoviesListResult> homeGridByParent(
    int pt, {
    int leve = homeGridLeve,
    int pagesize = 6,
  }) => vodList(pt: pt, leve: leve, pagesize: pagesize);

  /// `/api/vod/?ac=detail`
  Future<FlutterMoviesListResult> vodList({
    int? pt,
    int? t,
    int? pg,
    String? wd,
    int? h,
    int? pagesize,
    int? leve,
    String? order,
  }) async {
    final json = await _getJson(
      vodPath,
      vodQuery(
        pt: pt,
        t: t,
        pg: pg,
        wd: wd,
        h: h,
        pagesize: pagesize,
        leve: leve,
        order: order,
      ),
    );
    return FlutterMoviesListResult.fromJson(json);
  }

  /// 影片详情：`/api/vod/?ac=detail&ids=<id>`。
  Future<FlutterMoviesVideoDetail> videoDetail(Object id) async {
    final json = await _getJson(vodPath, <String, dynamic>{
      'ac': 'detail',
      'ids': '$id',
    });
    final rows = FlutterMoviesJson.asList(json['list']);
    if (rows.isEmpty) throw const FlutterMoviesException('影片详情不存在');
    return FlutterMoviesVideoDetail.fromJson(
      FlutterMoviesJson.asMap(rows.first),
    );
  }

  /// 分类浏览：子类 `t` + 页码，源站 order=vod_level。
  Future<FlutterMoviesListResult> categoryMovies({
    required int t,
    int pg = 1,
    int pagesize = categoryPageSize,
    String order = 'vod_level',
  }) => vodList(t: t, pg: pg, pagesize: pagesize, order: order);

  /// 排行榜：父类 `pt` + 页码，源站 order=vod_hits_month（当月点击）。
  Future<FlutterMoviesListResult> ranking({
    required int pt,
    int pg = 1,
    int pagesize = rankingPageSize,
  }) => vodList(pt: pt, pg: pg, pagesize: pagesize, order: 'vod_hits_month');

  /// 搜索：`wd` + 页码，源站 order=vod_time（标签搜索走同一个接口）。
  Future<FlutterMoviesListResult> search(
    String keyword, {
    int pg = 1,
    int pagesize = categoryPageSize,
  }) {
    final value = keyword.trim();
    if (value.isEmpty) throw ArgumentError('搜索关键词不能为空');
    return vodList(wd: value, pg: pg, pagesize: pagesize, order: 'vod_time');
  }

  /// 最近更新（源站注释里的 `h=几小时内的数据`）。
  Future<FlutterMoviesListResult> updates({
    int hours = 24,
    int pg = 1,
    int pagesize = categoryPageSize,
  }) => vodList(h: hours, pg: pg, pagesize: pagesize, order: 'vod_time');

  /// 父类列表（getPcategory 固定 pt=0）。
  Future<List<FlutterMoviesCategory>> parentCategories() =>
      _categoryList(parentCategoriesPath, <String, dynamic>{'pt': 0});

  /// 指定父类下的子类。
  Future<List<FlutterMoviesCategory>> subcategories(int pt) =>
      _categoryList(subcategoriesPath, <String, dynamic>{'pt': pt});

  /// 全部分类（不含父类）。
  Future<List<FlutterMoviesCategory>> allCategories() =>
      _categoryList(allCategoriesPath, null);

  /// 把 CMS 里的相对图片地址补成绝对地址。
  String? imageUrl(String? raw) => resolveImageUrl(raw, webUrl: webUrl);

  static String? resolveImageUrl(String? raw, {String webUrl = defaultWebUrl}) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    final parsed = Uri.tryParse(value);
    if (parsed != null &&
        (parsed.scheme == 'http' || parsed.scheme == 'https')) {
      return value;
    }
    if (value.startsWith('//')) return 'https:$value';
    final base = webUrl.endsWith('/') ? webUrl : '$webUrl/';
    return value.startsWith('/') ? '$base${value.substring(1)}' : '$base$value';
  }

  void dispose() => _dio.close();

  Future<List<FlutterMoviesCategory>> _categoryList(
    String path,
    Map<String, dynamic>? query,
  ) async {
    final json = await _getJson(path, query);
    return FlutterMoviesJson.asMapList(
      json['list'],
    ).map(FlutterMoviesCategory.fromJson).toList(growable: false);
  }

  Future<Map<String, dynamic>> _getJson(
    String path, [
    Map<String, dynamic>? query,
  ]) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        '$_origin$path',
        queryParameters: query,
      );
    } on DioException catch (error) {
      throw FlutterMoviesException(
        _messageFor(error),
        statusCode: error.response?.statusCode,
      );
    }
    final status = response.statusCode;
    final data = response.data;
    if (data is Map) {
      final json = FlutterMoviesJson.asMap(data);
      final code = int.tryParse(FlutterMoviesJson.asString(json['code']));
      if (code != null && code != 1) {
        final message = FlutterMoviesJson.asString(json['msg']).trim();
        throw FlutterMoviesException(
          message.isEmpty ? '影视频道返回错误（code=$code）' : message,
          statusCode: status,
        );
      }
      return json;
    }
    if (status != null && status >= 400) {
      throw FlutterMoviesException('请求失败：HTTP $status', statusCode: status);
    }
    throw const FlutterMoviesException('影视频道返回的数据格式无法解析');
  }

  String get _origin => webUrl.endsWith('/') ? webUrl : '$webUrl/';

  String _messageFor(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return '影视频道连接超时';
      case DioExceptionType.connectionError:
        return '无法连接影视频道，请检查网络';
      case DioExceptionType.cancel:
        return '影视频道请求已取消';
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return status == null ? '影视频道请求失败' : '影视频道请求失败：HTTP $status';
      case DioExceptionType.badCertificate:
        return '影视频道证书校验失败';
      case DioExceptionType.unknown:
        final message = error.message?.trim() ?? '';
        return message.isEmpty ? '影视频道请求失败' : message;
    }
  }
}
