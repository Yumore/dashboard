/// Fields accepted by the forum fast login form.
///
/// Ported from `tsdm_client/lib/features/authentication/repository/models/user_credential.dart`.
enum TsdmLoginField {
  /// Login with the username.
  username,

  /// Login with the email.
  email,

  /// Login with the uid.
  uid;

  /// Form field value of this login field.
  @override
  String toString() {
    return switch (this) {
      TsdmLoginField.username => 'username',
      TsdmLoginField.email => 'email',
      TsdmLoginField.uid => 'uid',
    };
  }
}

/// Security question answered together with the credential.
class TsdmSecurityQuestion {
  const TsdmSecurityQuestion({required this.questionId, required this.answer});

  /// Question id, the `questionid` form field.
  final String questionId;

  /// Answer text, the `answer` form field.
  final String answer;

  /// Form representation.
  Map<String, String> toJson() => {'questionid': questionId, 'answer': answer};
}

/// A login credential.
///
/// No credential value is ever hard-coded in this port; callers inject the
/// values and the login form field names stay exactly as the source sent them.
class TsdmUserCredential {
  const TsdmUserCredential({
    required this.loginField,
    required this.loginFieldValue,
    required this.password,
    required this.tsdmVerify,
    this.securityQuestion,
  });

  /// Which form field carries the login name.
  final TsdmLoginField loginField;

  /// Login name value.
  final String loginFieldValue;

  /// Password value.
  final String password;

  /// Value of the `tsdm_verify` form field.
  final String tsdmVerify;

  /// Optional security question.
  final TsdmSecurityQuestion? securityQuestion;

  /// Build the login form body.
  Map<String, String> toJson() {
    final data = <String, String>{
      'fastloginfield': loginField.toString(),
      'username': loginFieldValue,
      'password': password,
      'tsdm_verify': tsdmVerify,
    };
    final question = securityQuestion;
    if (question != null) {
      data.addAll(question.toJson());
    }
    return data;
  }
}
