import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_custom_button.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_custom_text_field.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_demo_config.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_demo_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_fade_in.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_form_mode.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_main_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_palette.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_theme.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_validations.dart';

/// State of the FlutterSocialAppUIKit login screen
/// (source `lib/views/screens/auth/login.dart:18-231`).
///
/// The source has one screen with three modes — `LOGIN`, `REGISTER` and
/// `FORGOT_PASSWORD` — and swaps its own fields and footer links between them;
/// there is no separate register or reset route, so neither does the port.
///
/// Faithful detail: the source's `login()` calls `form.save()` and then always
/// pushes the tab shell; the `form.validate()` branch is commented out
/// (`login.dart:33-39`). The port keeps that — errors appear while typing
/// because the form uses `AutovalidateMode.onUserInteraction`, but `Submit`
/// does not block on them.
class FlutterSocialAppUIKitDemoPageState
    extends State<FlutterSocialAppUIKitDemoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final bool _loading = false;
  FlutterSocialAppUIKitFormMode _formMode = FlutterSocialAppUIKitFormMode.login;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() {
    final FormState form = _formKey.currentState!;
    form.save();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            const FlutterSocialAppUIKitMainPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Theme(
      data: FlutterSocialAppUIKitTheme.light(),
      child: Scaffold(
        body: Row(
          children: <Widget>[
            _buildIllustrationContainer(screenWidth),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: _buildFormContainer(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Source `buildLottieContainer`: at widths of 700 px and above it occupies
  /// half of the screen and centres the bundled chat animation; below that it
  /// collapses to zero width.
  ///
  /// The host has no `lottie` dependency, so the JSON animation is not bundled
  /// and the panel shows a static chat glyph over the same 30%-opacity accent.
  Widget _buildIllustrationContainer(double screenWidth) {
    if (screenWidth < 700.0) {
      return const SizedBox.shrink();
    }
    return Container(
      width: screenWidth * 0.5,
      color: FlutterSocialAppUIKitPalette.secondary.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(Icons.forum_outlined, size: 200.0, color: Colors.white70),
      ),
    );
  }

  Widget _buildFormContainer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FlutterSocialAppUIKitFadeIn(
          child: Text(
            FlutterSocialAppUIKitDemoConfig.appName,
            style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 70.0),
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: _buildForm(),
        ),
        if (_formMode == FlutterSocialAppUIKitFormMode.login)
          FlutterSocialAppUIKitFadeIn(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _formMode =
                            FlutterSocialAppUIKitFormMode.forgotPassword;
                      });
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20.0),
        _buildButton(),
        if (_formMode == FlutterSocialAppUIKitFormMode.login)
          FlutterSocialAppUIKitFadeIn(
            child: _buildAccountSwitch(isLogin: true),
          ),
        if (_formMode != FlutterSocialAppUIKitFormMode.login)
          _buildAccountSwitch(isLogin: false),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (_formMode == FlutterSocialAppUIKitFormMode.register)
          Column(
            children: <Widget>[
              FlutterSocialAppUIKitCustomTextField(
                enabled: !_loading,
                hintText: 'Name',
                textInputAction: TextInputAction.next,
                validator: FlutterSocialAppUIKitValidations.name,
                onSaved: (String? value) {},
                focusNode: _nameFocusNode,
                nextFocusNode: _emailFocusNode,
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        FlutterSocialAppUIKitFadeIn(
          child: FlutterSocialAppUIKitCustomTextField(
            enabled: !_loading,
            hintText: 'Email',
            textInputAction: TextInputAction.next,
            validator: FlutterSocialAppUIKitValidations.email,
            onSaved: (String? value) {},
            focusNode: _emailFocusNode,
            nextFocusNode: _passwordFocusNode,
          ),
        ),
        if (_formMode != FlutterSocialAppUIKitFormMode.forgotPassword)
          FlutterSocialAppUIKitFadeIn(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20.0),
                FlutterSocialAppUIKitCustomTextField(
                  enabled: !_loading,
                  hintText: 'Password',
                  textInputAction: TextInputAction.done,
                  validator: FlutterSocialAppUIKitValidations.password,
                  submitAction: _login,
                  obscureText: true,
                  onSaved: (String? value) {},
                  focusNode: _passwordFocusNode,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildButton() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return FlutterSocialAppUIKitFadeIn(
      child: FlutterSocialAppUIKitCustomButton(
        label: 'Submit',
        onPressed: _login,
      ),
    );
  }

  Widget _buildAccountSwitch({required bool isLogin}) {
    // Source `login.dart:131-160` lays this footer out as a `Row`. On a narrow
    // phone the sentence plus its button exceed the form width, so the port
    // uses a `Wrap`: same widgets and same centred appearance, but the button
    // moves to a second line instead of painting an overflow.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(isLogin ? "Don't have an account?" : 'Already have an account?'),
        TextButton(
          onPressed: () {
            setState(() {
              _formMode = isLogin
                  ? FlutterSocialAppUIKitFormMode.register
                  : FlutterSocialAppUIKitFormMode.login;
            });
          },
          child: Text(isLogin ? 'Register' : 'Login'),
        ),
      ],
    );
  }
}
