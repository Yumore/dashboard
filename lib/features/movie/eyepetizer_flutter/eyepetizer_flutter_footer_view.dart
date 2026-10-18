import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_load_status.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_footer_view_state.dart';
import 'package:flutter/material.dart';

/// `lib/widgets/footer_view.dart` → `FooterView`.
///
/// The footer is always laid out and only becomes visible while loading, so the
/// list's scroll extent does not jump when a page finishes.
class EyepetizerFlutterFooterView extends StatefulWidget {
  const EyepetizerFlutterFooterView({super.key, this.loadStatus});

  final EyepetizerFlutterLoadStatus? loadStatus;

  @override
  State<EyepetizerFlutterFooterView> createState() =>
      EyepetizerFlutterFooterViewState();
}
