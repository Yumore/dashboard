import 'dart:async';

import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_countdown_button.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterCountdownButton].
class EyepetizerFlutterCountdownButtonState
    extends State<EyepetizerFlutterCountdownButton> {
  Timer? _countDownTimer;
  String? _label;

  /// `CountDownState.startCountDown`'s label rule: while
  /// `period - tick > 0` show `'<remaining>秒'`, otherwise show the source's
  /// hard-coded reset label `'发送验证码'` (which is *not* the button's initial
  /// `text`, another source quirk the port keeps).
  static String labelFor({required int period, required int tick}) {
    if (period - tick > 0) return '${period - tick}秒';
    return '发送验证码';
  }

  @override
  void dispose() {
    _countDownTimer?.cancel();
    _countDownTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _startCountDown,
      style: ElevatedButton.styleFrom(
        backgroundColor: _countDownTimer == null
            ? Colors.blueAccent
            : Colors.black12,
      ),
      child: Text(
        _label ?? widget.text ?? '',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  void _startCountDown() {
    widget.onCountDownStart?.call();
    _countDownTimer?.cancel();
    _countDownTimer = Timer.periodic(Duration(seconds: widget.interval), (
      timer,
    ) {
      setState(() {
        _label = labelFor(period: widget.period, tick: timer.tick);
        if (widget.period - timer.tick <= 0) {
          _countDownTimer?.cancel();
          _countDownTimer = null;
        }
      });
    });
  }
}
