import 'package:dio/dio.dart';

import 'pixez_auth_required_exception.dart';

/// True when the failure means the injected token is missing or rejected.
bool pixezIsAuthFailure(Object error) {
  if (error is PixezAuthRequiredException) return true;
  if (error is DioException) {
    final status = error.response?.statusCode;
    return status == 401 || status == 403;
  }
  return false;
}

/// Short user-facing message for a failed pixiv request.
String pixezErrorMessage(Object error) {
  if (error is PixezAuthRequiredException) {
    return PixezAuthRequiredException.message;
  }
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status != null) return '请求失败（HTTP $status）';
    return '网络请求失败';
  }
  return error.toString();
}
