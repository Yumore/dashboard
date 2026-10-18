import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_countdown_button_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/login/widgets/countdown_button.dart`'s callback typedef.
typedef EyepetizerFlutterOnCountDownStart = void Function();

/// `lib/pages/login/widgets/countdown_button.dart` → `CountDownButton`.
///
/// The source's constructor copied `text`/`period`/`interval` into the state
/// instead of reading them off the widget, so changing them after the first
/// build did nothing. The port reads them from the widget (otherwise identical)
/// and keeps the label rule in [EyepetizerFlutterCountdownButtonState.labelFor]
/// so it can be asserted without a timer.
class EyepetizerFlutterCountdownButton extends StatefulWidget {
  const EyepetizerFlutterCountdownButton({
    super.key,
    this.text,
    this.period = 60,
    this.interval = 1,
    this.onCountDownStart,
  });

  final String? text;
  final int period;
  final int interval;
  final EyepetizerFlutterOnCountDownStart? onCountDownStart;

  @override
  State<EyepetizerFlutterCountdownButton> createState() =>
      EyepetizerFlutterCountdownButtonState();
}
