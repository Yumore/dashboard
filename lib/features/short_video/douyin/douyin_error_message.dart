import 'package:dashboard/features/short_video/douyin/douyin_api_exception.dart';
import 'package:dashboard/features/short_video/douyin/douyin_signature_rejected.dart';

/// 把控制器/客户端异常转成界面文案（宿主 `dytt_error_message.dart` 同款）。
String douyinErrorMessage(Object error) {
  if (error is DouyinSignatureRejected) {
    return error.message;
  }
  if (error is DouyinApiException) {
    return error.message;
  }
  return '抖音请求失败：$error';
}
