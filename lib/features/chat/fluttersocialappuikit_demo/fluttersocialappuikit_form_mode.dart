/// The three states of the FlutterSocialAppUIKit login screen
/// (source `lib/util/enum.dart:1`, `enum FormMode {LOGIN, REGISTER,
/// FORGOT_PASSWORD}`).
///
/// The source screen never opens a separate register or reset screen: it swaps
/// its own form fields and footer links. The port keeps that single-screen
/// behaviour, so `login`, `register` and `reset` in the demo are these modes.
enum FlutterSocialAppUIKitFormMode { login, register, forgotPassword }
