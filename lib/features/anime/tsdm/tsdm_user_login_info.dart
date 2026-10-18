import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';

/// Login info of the authenticated forum user.
///
/// Ported from `tsdm_client/lib/shared/models/user_login_info.dart`. The
/// password is intentionally not part of this model, so it can never be
/// persisted or logged by the port.
class TsdmUserLoginInfo {
  const TsdmUserLoginInfo({this.username, this.uid});

  /// Username of the logged user.
  final String? username;

  /// Uid of the logged user.
  final int? uid;

  /// An empty login info.
  factory TsdmUserLoginInfo.empty() => const TsdmUserLoginInfo();

  /// Whether both the username and the uid are known.
  bool get isComplete => username != null && uid != null;

  /// Whether both the username and the uid are unknown.
  bool get isEmpty => username == null && uid == null;

  @override
  String toString() =>
      'UserLoginInfo(username: ${username?.obscured()}, uid: ${uid?.toString().obscured(4)})';
}
