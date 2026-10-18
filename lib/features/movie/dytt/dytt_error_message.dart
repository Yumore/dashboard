import 'package:dashboard/features/movie/dytt/dytt_api_exception.dart';
import 'package:dashboard/features/movie/dytt/dytt_signature_unavailable.dart';

/// 把任意异常转成页面可展示的一行文案。
String dyttErrorMessage(Object error) {
  if (error is DyttApiException) return error.message;
  if (error is DyttSignatureUnavailable) return error.message;
  return '$error';
}
