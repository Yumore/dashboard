import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_home_page_state.dart';
import 'package:flutter/material.dart';

/// The module entry the host's `MovieModulePageState` opens.
///
/// It is a launcher, not a copy of any source screen: the source app had a
/// bottom-navigation shell, and these are the four surfaces of it that the
/// already-ported `eyepetizer/` module does not cover.
class EyepetizerFlutterHomePage extends StatefulWidget {
  const EyepetizerFlutterHomePage({super.key});

  @override
  State<EyepetizerFlutterHomePage> createState() =>
      EyepetizerFlutterHomePageState();
}
