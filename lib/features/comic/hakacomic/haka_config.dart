import 'package:dashboard/features/comic/hakacomic/haka_api.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_quality.dart';

/// Static credentials and per-call knobs of the picacomic schema.
///
/// The signing constants are the public ones shipped by the upstream app
/// (`haka_comic/lib/network/utils.dart:5-8`), not user secrets.
class HakaConfig {
  const HakaConfig({
    this.api = HakaApi.picacomic,
    this.baseUrl,
    this.token = '',
    this.imageQuality = HakaImageQuality.original,
    this.appChannel = '1',
  });

  static const String apiKey = 'C69BAF41DA5ABD1FFEDC6D2FEA56B';

  static const String secretKey =
      r'~d}$Q7$eIni=V)9\RK/P.RM4;9[7|@/CA}b~OW!3?EV`:<>M7pddUBL5n|0/*Cn';

  static const String nonce = '4ce7a7aa759b40f794d189a88b84aba8';

  static const String appVersion = '2.2.1.3.3.4';

  static const String appBuildVersion = '45';

  static const String accept = 'application/vnd.picacomic.com.v1+json';

  /// Selected schema host. Ignored when [baseUrl] is set.
  final HakaApi api;

  /// Injectable base URL. Defaults to [HakaApi.picacomic]'s host.
  final String? baseUrl;

  /// `authorization` header value, empty when anonymous.
  final String token;

  final HakaImageQuality imageQuality;

  final String appChannel;

  /// Effective base URL, always ending with `/`.
  String get resolvedBaseUrl {
    final raw = baseUrl ?? api.host;
    return raw.endsWith('/') ? raw : '$raw/';
  }

  Map<String, String> get defaultHeaders => {
    'accept': accept,
    'User-Agent': 'okhttp/3.8.1',
    'Content-Type': 'application/json; charset=UTF-8',
    'api-key': apiKey,
    'app-build-version': appBuildVersion,
    'app-platform': 'android',
    'app-uuid': 'defaultUuid',
    'app-version': appVersion,
    'nonce': nonce,
    'app-channel': appChannel,
  };

  HakaConfig copyWith({
    HakaApi? api,
    String? baseUrl,
    String? token,
    HakaImageQuality? imageQuality,
    String? appChannel,
  }) {
    return HakaConfig(
      api: api ?? this.api,
      baseUrl: baseUrl ?? this.baseUrl,
      token: token ?? this.token,
      imageQuality: imageQuality ?? this.imageQuality,
      appChannel: appChannel ?? this.appChannel,
    );
  }
}
