import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_user_info.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_edit_person_data_page_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/mine/edit_personal_data_page.dart` → `EditPersonDataPage`.
///
/// The edit-profile form: cover and avatar pickers that upload immediately,
/// seven text fields, and a save that posts every value to
/// `POST /api/v5/userInfo/edit`.
class EyepetizerFlutterEditPersonDataPage extends StatefulWidget {
  const EyepetizerFlutterEditPersonDataPage({
    super.key,
    this.userInfo,
    this.repository,
  });

  final EyepetizerFlutterUserInfo? userInfo;
  final EyepetizerFlutterPersonRepository? repository;

  /// `EditPersonDataState`'s two picker targets.
  static const String typeCover = 'type_cover';
  static const String typeAvatar = 'type_avatar';

  @override
  State<EyepetizerFlutterEditPersonDataPage> createState() =>
      EyepetizerFlutterEditPersonDataPageState();
}
