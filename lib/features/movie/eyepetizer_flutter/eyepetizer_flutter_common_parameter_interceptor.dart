import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_config.dart';
import 'package:dio/dio.dart';

/// Adds the eight device coordinates the source app appended to *every* request
/// (`lib/http/interceptors/common_parameter_interceptor.dart:12-24`).
///
/// The keys and values are verbatim, including `first_channel`/`last_channel`
/// and `system_version_code`, which do not use camelCase like their siblings.
class EyepetizerFlutterCommonParameterInterceptor extends Interceptor {
  const EyepetizerFlutterCommonParameterInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll(<String, dynamic>{
      'udid': EyepetizerFlutterConfig.udid,
      'vc': EyepetizerFlutterConfig.vc,
      'vn': EyepetizerFlutterConfig.vn,
      'size': EyepetizerFlutterConfig.size,
      'deviceModel': EyepetizerFlutterConfig.deviceModel,
      'first_channel': EyepetizerFlutterConfig.firstChannel,
      'last_channel': EyepetizerFlutterConfig.lastChannel,
      'system_version_code': EyepetizerFlutterConfig.systemVersionCode,
    });
    handler.next(options);
  }
}
