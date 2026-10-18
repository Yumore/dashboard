/// Exceptions thrown by the tsdm client layer.
///
/// Ported from `tsdm_client/lib/exceptions/exceptions.dart`, keeping the same
/// failure categories the repositories map http/parse problems into.
sealed class TsdmException implements Exception {
  const TsdmException();

  /// Human readable message.
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Http request failed with a non 200 status code or without a status code.
final class HttpRequestFailedException extends TsdmException {
  const HttpRequestFailedException(this.statusCode);

  /// Response status code, null when the request never completed.
  final int? statusCode;

  @override
  String get message => 'http request failed with status code $statusCode';
}

/// Http handshake failed (transport level error).
final class HttpHandshakeFailedException extends TsdmException {
  const HttpHandshakeFailedException(
    this.detail, {
    this.statusCode,
    this.headers,
  });

  /// Transport level detail message.
  final String detail;

  /// Optional response status code.
  final int? statusCode;

  /// Optional response headers.
  final Map<String, String>? headers;

  @override
  String get message => 'http handshake failed: $detail';
}

/// The server returned an application level failure.
final class ServerRespFailure extends TsdmException {
  const ServerRespFailure({required this.status, this.message = ''});

  /// Server status code.
  final int status;

  /// Server message, empty when the server sent none.
  @override
  final String message;

  @override
  String toString() => 'ServerRespFailure: status=$status, message=$message';
}

/// The login layer hash was not found in the login form response.
final class LoginFormHashNotFoundException extends TsdmException {
  const LoginFormHashNotFoundException();

  @override
  String get message => 'login form hash not found';
}

/// The form hash was not found in the login form response.
final class LoginInvalidFormHashException extends TsdmException {
  const LoginInvalidFormHashException();

  @override
  String get message => 'login form hash not found in login form';
}

/// Incorrect username or password.
final class LoginInvalidCredentialException extends TsdmException {
  const LoginInvalidCredentialException();

  @override
  String get message => 'invalid username or password';
}

/// Too many login attempts.
final class LoginAttemptLimitException extends TsdmException {
  const LoginAttemptLimitException();

  @override
  String get message => 'login attempt limit reached';
}

/// Incorrect captcha answer.
final class LoginIncorrectCaptchaException extends TsdmException {
  const LoginIncorrectCaptchaException();

  @override
  String get message => 'incorrect captcha answer';
}

/// The logged user info was not found in the document.
final class LoginUserInfoNotFoundException extends TsdmException {
  const LoginUserInfoNotFoundException();

  @override
  String get message => 'user info not found in document';
}

/// Any other login error.
final class LoginOtherErrorException extends TsdmException {
  const LoginOtherErrorException(this.detail);

  /// Detail of the failure.
  final String detail;

  @override
  String get message => 'login failed: $detail';
}

/// Logout failed.
final class LogoutFailedException extends TsdmException {
  const LogoutFailedException();

  @override
  String get message => 'logout failed';
}

/// The form hash required by logout was not found.
final class LogoutFormHashNotFoundException extends TsdmException {
  const LogoutFormHashNotFoundException();

  @override
  String get message => 'logout form hash not found';
}

/// The switched session is not authenticated.
final class SwitchUserNotAuthedException extends TsdmException {
  const SwitchUserNotAuthedException();

  @override
  String get message => 'switched user is not authenticated';
}

/// A required html node was not found while parsing a document.
final class HtmlNodeNotFoundException extends TsdmException {
  const HtmlNodeNotFoundException(this.selector);

  /// Selector of the missing node.
  final String selector;

  @override
  String get message => 'html node not found: $selector';
}

/// A thread content page could not be parsed.
final class ThreadContentNotFoundException extends TsdmException {
  const ThreadContentNotFoundException();

  @override
  String get message => 'thread content not found';
}
