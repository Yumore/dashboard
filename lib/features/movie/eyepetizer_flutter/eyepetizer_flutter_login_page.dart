import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_account_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_login_page_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/login/login_page.dart` → `LoginPage`.
///
/// Checks the two fields, posts them to the account host, writes the returned
/// `Login` into `user_data`, and pops `true`. The source also fired a global
/// `LoginEvent`; this module has no event bus, so the caller reloads from
/// preferences when the route resolves instead (see `MinePage`).
class EyepetizerFlutterLoginPage extends StatefulWidget {
  const EyepetizerFlutterLoginPage({super.key, this.repository});

  final EyepetizerFlutterAccountRepository? repository;

  @override
  State<EyepetizerFlutterLoginPage> createState() =>
      EyepetizerFlutterLoginPageState();
}
