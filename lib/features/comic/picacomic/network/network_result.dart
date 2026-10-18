import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dio/dio.dart';

/// Wraps a raw request so failures become `Res.error` instead of throwing.
///
/// Ports the `try/catch -> Res.fromErrorRes` pattern repeated across
/// PicaComic's `*_main_network.dart` files.
Future<Res<T>> guardRequest<T>(Future<T> Function() request) async {
  try {
    return Res(await request());
  } on DioException catch (error) {
    return Res.error(describeDioError(error));
  } catch (error) {
    return Res.error(error.toString());
  }
}

/// Human-readable message for a failed request, including the HTTP status.
String describeDioError(DioException error) {
  final status = error.response?.statusCode;
  final data = error.response?.data;
  final buffer = StringBuffer('Network Error');
  if (status != null) buffer.write(' $status');
  if (data is String && data.isNotEmpty) {
    buffer.write(' ${data.length > 200 ? data.substring(0, 200) : data}');
  } else if (error.message != null && error.message!.isNotEmpty) {
    buffer.write(' ${error.message}');
  }
  return buffer.toString();
}
