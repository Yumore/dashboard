/// Thrown before any socket is opened when a pixiv app-api call needs a login
/// token but the injectable [PixezAuthStore] has none.
///
/// The source app's `RefreshTokenInterceptor` rejects the request when no
/// account is configured; this port surfaces the same condition as a typed
/// exception so every controller can render the same "需要登录令牌" state.
class PixezAuthRequiredException implements Exception {
  const PixezAuthRequiredException();

  static const String message = '需要登录令牌';

  @override
  String toString() => message;
}
