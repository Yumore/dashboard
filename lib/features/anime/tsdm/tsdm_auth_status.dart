import 'package:dashboard/features/anime/tsdm/tsdm_user_login_info.dart';

/// Authentication status pushed by the authentication layer.
///
/// Ported from `tsdm_client/lib/features/authentication/repository/models/auth_status.dart`.
sealed class TsdmAuthStatus {
  const TsdmAuthStatus();
}

/// The authentication state is not known yet.
final class TsdmAuthStatusUnknown extends TsdmAuthStatus {
  const TsdmAuthStatusUnknown();
}

/// The authentication state is being checked.
final class TsdmAuthStatusLoading extends TsdmAuthStatus {
  const TsdmAuthStatusLoading();
}

/// No user is authenticated.
final class TsdmAuthStatusNotAuthed extends TsdmAuthStatus {
  const TsdmAuthStatusNotAuthed();
}

/// A user is authenticated.
final class TsdmAuthStatusAuthed extends TsdmAuthStatus {
  const TsdmAuthStatusAuthed(this.userInfo);

  /// Info of the authenticated user.
  final TsdmUserLoginInfo userInfo;
}
