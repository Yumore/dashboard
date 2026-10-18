import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_home_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_login_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_palette.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_register_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_reset_password_page.dart';
import 'package:flutter/material.dart';

/// Port of the source log-in screen (source `lib/views/login.dart`).
///
/// Faithful detail: the source builds a `GlobalKey<FormState>` and a `Form` but
/// never calls `validate()` and attaches no `validator` to either field, so
/// tapping SIGN IN always continues regardless of input. That behaviour is kept
/// — no validation was invented for the port.
class FlutterSocialLoginPageState extends State<FlutterSocialLoginPage> {
  final _formKey = GlobalKey<FormState>();

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final pageTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Log In.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 45.0,
          ),
        ),
        const Text(
          'We missed you!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final emailField = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Email Address',
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(Icons.mail_outline, color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
    );

    final passwordField = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      obscureText: true,
    );

    final loginForm = Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Form(
        key: _formKey,
        child: Column(children: <Widget>[emailField, passwordField]),
      ),
    );

    final loginBtn = Container(
      margin: const EdgeInsets.only(top: 40.0),
      height: 60.0,
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: ElevatedButton(
        onPressed: () => _open(const FlutterSocialHomePage()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
        child: const Text(
          'SIGN IN',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0),
        ),
      ),
    );

    final forgotPassword = Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: InkWell(
        onTap: () => _open(const FlutterSocialResetPasswordPage()),
        child: const Center(
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    final newUser = Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: InkWell(
        onTap: () => _open(const FlutterSocialRegisterPage()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'New User?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              ' Create account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 150.0, left: 30.0, right: 30.0),
          constraints: BoxConstraints(minHeight: size.height),
          width: size.width,
          decoration: const BoxDecoration(
            gradient: FlutterSocialPalette.primaryGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              pageTitle,
              loginForm,
              loginBtn,
              forgotPassword,
              newUser,
            ],
          ),
        ),
      ),
    );
  }
}
