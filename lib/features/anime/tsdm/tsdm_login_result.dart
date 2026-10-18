import 'package:dashboard/features/anime/tsdm/tsdm_user_login_info.dart';

/// Login form hashes of the forum login page.
///
/// Ported from `tsdm_client/lib/features/authentication/repository/models/hash.dart`.
class TsdmLoginHash {
  const TsdmLoginHash({required this.formHash, required this.loginHash});

  /// Value of the `formhash` hidden input.
  final String formHash;

  /// Value of the layer login hash found in the login form url.
  final String loginHash;
}

/// `values` object of a successful login response.
class TsdmLoginValue {
  const TsdmLoginValue({this.username, this.userGroup, this.uid});

  /// Logged username.
  final String? username;

  /// User group of the logged user.
  final String? userGroup;

  /// Logged uid.
  final String? uid;
}

/// `extra` object of a login response.
class TsdmLoginExtra {
  const TsdmLoginExtra({this.showDialog, this.locationTime, this.extraJs});

  /// `showdialog` field.
  final String? showDialog;

  /// `locationtime` field.
  final String? locationTime;

  /// `extrajs` field.
  final String? extraJs;
}

/// A login response as returned by the mobile login endpoint.
///
/// Ported from `tsdm_client/lib/features/authentication/repository/models/login_result.dart`
/// (which used `dart_mappable` code generation; the port maps the same json
/// keys by hand, including the `usergroup` key of the `uid` sibling fields).
class TsdmLoginResult {
  const TsdmLoginResult({
    required this.status,
    required this.message,
    this.extra,
    this.values,
  });

  /// Success message of a successful login.
  static const messageSuccess = 'location_login_succeed_mobile';

  /// Message of an invalid credential response.
  static const messageLoginInvalid = 'login_invalid';

  /// Message of an invalid captcha response.
  static const messageCaptchaError = 'err_login_captcha_invalid';

  /// Server status, 0 means the login succeeded.
  final int status;

  /// Server message.
  final String message;

  /// Optional extra data.
  final TsdmLoginExtra? extra;

  /// Optional account values.
  final TsdmLoginValue? values;

  /// Build from a decoded json map.
  ///
  /// Throws [FormatException] when a required field is missing or mistyped.
  factory TsdmLoginResult.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final message = json['message'];
    if (status is! int || message is! String) {
      throw const FormatException('invalid login result json');
    }
    final extraRaw = json['extra'];
    final extra = extraRaw is Map
        ? TsdmLoginExtra(
            showDialog: extraRaw['showdialog'] as String?,
            locationTime: extraRaw['locationtime'] as String?,
            extraJs: extraRaw['extrajs'] as String?,
          )
        : null;
    final valuesRaw = json['values'];
    final values = valuesRaw is Map
        ? TsdmLoginValue(
            username: valuesRaw['username'] as String?,
            userGroup: valuesRaw['usergroup'] as String?,
            uid: valuesRaw['uid'] as String?,
          )
        : null;
    return TsdmLoginResult(
      status: status,
      message: message,
      extra: extra,
      values: values,
    );
  }

  /// Login info of this result, null when [values] is missing.
  TsdmUserLoginInfo? toTsdmUserLoginInfo() {
    final v = values;
    if (v == null) {
      return null;
    }
    final username = v.username;
    final uid = v.uid == null ? null : int.tryParse(v.uid!);
    if (username == null || uid == null) {
      return null;
    }
    return TsdmUserLoginInfo(username: username, uid: uid);
  }
}
