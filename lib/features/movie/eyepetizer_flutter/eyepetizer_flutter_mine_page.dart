import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_mine_page_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/mine/mine_page.dart` → `MinePage`.
///
/// The profile screen: who is signed in (read from `user_data`), the two
/// shortcut tiles, and the row list. Package version comes from
/// `package_info_plus` (the host's package for the source's `package_info`).
class EyepetizerFlutterMinePage extends StatefulWidget {
  const EyepetizerFlutterMinePage({super.key});

  @override
  State<EyepetizerFlutterMinePage> createState() =>
      EyepetizerFlutterMinePageState();
}
