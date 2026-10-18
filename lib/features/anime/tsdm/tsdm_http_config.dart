/// Default HTTP header values and misc request defaults of the tsdm client.
///
/// Values are the real defaults of the source project
/// (`lib/shared/models/settings.dart` + `SettingsRepository.buildDefaultDio`).
class TsdmHttpConfig {
  const TsdmHttpConfig._();

  /// Default browser-like accept header.
  static const accept =
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,'
      'application/signed-exchange;v=b3;q=0.7';

  /// Encoding the browser asks for.
  static const acceptEncoding = 'gzip, deflate, br';

  /// Language the browser asks for.
  static const acceptLanguage =
      'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6,zh-TW;q=0.5';

  /// Desktop Firefox user agent used when requesting a desktop layout.
  static const userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0';

  /// Cookie expiration time in seconds, kept the same as the server behavior.
  static const defaultCookieTime = 2592000;

  /// Content type of a form post.
  static const formContentType = 'application/x-www-form-urlencoded';

  /// Accept header used when fetching an image.
  static const imageAccept = 'image/avif,image/webp,*/*;q=0.8';
}
