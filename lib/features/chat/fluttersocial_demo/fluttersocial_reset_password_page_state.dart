import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_demo_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_palette.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_register_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_reset_password_page.dart';
import 'package:flutter/material.dart';

/// Port of the source password-reset screen (source `lib/views/reset_password.dart`).
///
/// The e-mail field has no validator and RESET never calls `validate()`, exactly
/// as in the source, so it always pushes the landing screen again.
class FlutterSocialResetPasswordPageState
    extends State<FlutterSocialResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final appBar = Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ],
      ),
    );

    const pageTitle = Text(
      'Reset Password',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 40.0,
      ),
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

    final resetPasswordForm = Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Form(
        key: _formKey,
        child: Column(children: <Widget>[emailField]),
      ),
    );

    final resetPasswordBtn = Container(
      margin: const EdgeInsets.only(top: 40.0),
      height: 60.0,
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: ElevatedButton(
        onPressed: () => _open(const FlutterSocialDemoPage()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
        child: const Text(
          'RESET',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0),
        ),
      ),
    );

    final newUser = Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: InkWell(
        onTap: () => _open(const FlutterSocialRegisterPage()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Or',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              ' Create new account',
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
          padding: const EdgeInsets.only(top: 40.0),
          constraints: BoxConstraints(minHeight: size.height),
          width: size.width,
          decoration: const BoxDecoration(
            gradient: FlutterSocialPalette.primaryGradient,
          ),
          child: Column(
            children: <Widget>[
              appBar,
              Container(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    pageTitle,
                    resetPasswordForm,
                    resetPasswordBtn,
                    newUser,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
