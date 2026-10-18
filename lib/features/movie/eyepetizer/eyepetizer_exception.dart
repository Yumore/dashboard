/// A 开眼 request failure that is safe to show and retry.
///
/// Mirrors `FlutterDouBanException` so every ported movie source fails the same
/// way. The source app only had `showError(e.toString())` on a toast
/// (`lib_utils/lib/toast_util.dart`), which is why the message is user-facing.
class EyepetizerException implements Exception {
  const EyepetizerException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
