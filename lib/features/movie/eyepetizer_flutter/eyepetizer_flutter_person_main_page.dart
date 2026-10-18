import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_main_page_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/mine/person_main_page.dart` → `PersonMainPage`.
///
/// A person's profile: a 365-high collapsing header plus one tab per
/// `tabInfo.tabList` entry (`首页` / `作品` / `专辑`).
///
/// `isMySelf` is a plain flag here. The source recovered it from the route
/// argument's **string length** — an `int` uid printed fewer than five
/// characters, a `UserInfo` object printed many — and
/// [isMyselfArgument] keeps that rule visible and testable even though the port
/// no longer routes through untyped arguments.
class EyepetizerFlutterPersonMainPage extends StatefulWidget {
  const EyepetizerFlutterPersonMainPage({
    super.key,
    required this.uid,
    this.isMySelf = false,
    this.repository,
  });

  final int uid;
  final bool isMySelf;
  final EyepetizerFlutterPersonRepository? repository;

  /// `PersonMainPageState`'s `isMySelf = arguments.toString().length > 4`.
  static bool isMyselfArgument(Object? argument) =>
      argument.toString().length > 4;

  @override
  State<EyepetizerFlutterPersonMainPage> createState() =>
      EyepetizerFlutterPersonMainPageState();
}
