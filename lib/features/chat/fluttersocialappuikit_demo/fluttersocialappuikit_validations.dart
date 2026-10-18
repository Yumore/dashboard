/// Form validators of the FlutterSocialAppUIKit static UI demo
/// (source `lib/util/validations.dart`).
///
/// The messages and the regular expressions are the source's, character for
/// character. The source's e-mail pattern is split across three adjacent string
/// literals (`lib/util/validations.dart:12-15`); concatenated it is the pattern
/// below.
class FlutterSocialAppUIKitValidations {
  const FlutterSocialAppUIKitValidations._();

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is Required.';
    }
    final RegExp nameExp = RegExp(r'^[A-za-zğüşöçİĞÜŞÖÇ ]+$');
    if (!nameExp.hasMatch(value)) {
      return 'Please enter only alphabetical characters.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an Email Address.';
    }
    final RegExp emailExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}"
      r"[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    );
    if (!emailExp.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Please enter a valid password.';
    }
    return null;
  }
}
