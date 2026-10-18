import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_endpoint.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_http.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_login.dart';

/// `lib/http/repository/login_repository.dart`, moved from static methods to an
/// instance so a screen (and a test) can inject a transport.
///
/// All three calls go to the **account** host, not the feed host, and all three
/// are `POST`s whose payload travels in the query string because
/// `HttpManager.request` passed non-`FormData` `data` to Dio as
/// `queryParameters`. The parameter names are the account API's, not the UI's:
/// the phone number is `username`.
class EyepetizerFlutterAccountRepository {
  EyepetizerFlutterAccountRepository({EyepetizerFlutterHttp? http})
    : _http = http ?? EyepetizerFlutterHttp();

  final EyepetizerFlutterHttp _http;

  EyepetizerFlutterHttp get http => _http;

  /// 获取验证码 — `POST /v1/api/sms/initialization` with
  /// `telephone=<phone>` and `type=sms`.
  Future<EyepetizerFlutterBaseData> getVerificationCode(
    String phoneNumber,
  ) async {
    final result = await _http.request(
      EyepetizerFlutterEndpoint.getVerificationCode,
      baseUrl: EyepetizerFlutterEndpoint.accountBaseUrl,
      data: <String, dynamic>{'telephone': phoneNumber, 'type': 'sms'},
      method: 'POST',
    );
    return EyepetizerFlutterBaseData.fromJson(result);
  }

  /// 注册 — `POST /v2/api/register` with `username`, `code`, `password`.
  ///
  /// The parameter order is the source's: `(phoneNumber, verificationCode,
  /// password)`. `RegisterPage` calls it with the code and password arguments
  /// swapped in its own signature, which cancels out — see
  /// `EyepetizerFlutterRegisterPageState.validate`.
  Future<EyepetizerFlutterBaseData> register(
    String phoneNumber,
    String verificationCode,
    String password,
  ) async {
    final result = await _http.request(
      EyepetizerFlutterEndpoint.register,
      baseUrl: EyepetizerFlutterEndpoint.accountBaseUrl,
      data: <String, dynamic>{
        'username': phoneNumber,
        'code': verificationCode,
        'password': password,
      },
      method: 'POST',
    );
    return EyepetizerFlutterBaseData.fromJson(result);
  }

  /// 登录 — `POST /v1/api/login` with `username` and `password`.
  Future<EyepetizerFlutterLogin> login(
    String phoneNumber,
    String password,
  ) async {
    final result = await _http.request(
      EyepetizerFlutterEndpoint.login,
      baseUrl: EyepetizerFlutterEndpoint.accountBaseUrl,
      data: <String, dynamic>{'username': phoneNumber, 'password': password},
      method: 'POST',
    );
    return EyepetizerFlutterLogin.fromJson(result);
  }

  void dispose() => _http.dispose();
}
