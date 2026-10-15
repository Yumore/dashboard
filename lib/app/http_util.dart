import 'package:dio/dio.dart';

class HttpUtil {
  static HttpUtil? _httpUtil;

  static HttpUtil get instance {
    _httpUtil ??= HttpUtil();
    return _httpUtil!;
  }

  late Dio dio;

  HttpUtil() {
    dio = Dio(BaseOptions());
  }

  Future<String?> httpGet(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool needLogin = false,
  }) async {
    try {
      var result = await dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.plain,
          //headers: header,
        ),
      );

      return result.data;
    } catch (e) {
      if (e is DioException) {
        dioErrorHandle(e);
      } else {
        throw AppError("网络请求失败");
      }
      return null;
    }
  }

  void dioErrorHandle(DioException e) {
    switch (e.type) {
      case DioExceptionType.cancel:
        throw AppError("请求被取消");
      case DioExceptionType.badResponse:
        throw AppError("请求失败:${e.response!.statusCode}");
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw AppError("网络连接超时,请稍后再试");
      default:
        throw AppError("请求失败,无法连接至服务器");
    }
  }
}

class AppError implements Exception {
  int? code;
  String message;

  AppError(this.message, {this.code});

  @override
  String toString() {
    return message;
  }
}
