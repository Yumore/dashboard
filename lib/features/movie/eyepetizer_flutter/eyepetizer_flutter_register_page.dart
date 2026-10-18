import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_account_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_register_page_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/login/register_page.dart` → `RegisterPage`.
///
/// Phone + verification code + password, the 60-second code button, and a
/// `POST /v2/api/register` on submit.
class EyepetizerFlutterRegisterPage extends StatefulWidget {
  const EyepetizerFlutterRegisterPage({super.key, this.repository});

  final EyepetizerFlutterAccountRepository? repository;

  @override
  State<EyepetizerFlutterRegisterPage> createState() =>
      EyepetizerFlutterRegisterPageState();
}
