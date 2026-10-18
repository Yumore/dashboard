import 'package:flutter/material.dart';

/// Entrance animation used by the FlutterSocialAppUIKit login form
/// (source `lib/util/extensions.dart`, the `fadeInList` extension).
///
/// The source uses `flutter_staggered_animations`' `AnimationConfiguration
/// .staggeredList` with a `FadeInAnimation` and a horizontal
/// `SlideAnimation` (offset 50 px) lasting 900 ms. The host does not depend on
/// that package, so the same fade and 50 px horizontal slide are reproduced
/// with Flutter's built-in implicit animation; the package's per-index stagger
/// delay is not reproduced, because it only delays decoration.
class FlutterSocialAppUIKitFadeIn extends StatelessWidget {
  const FlutterSocialAppUIKitFadeIn({
    required this.child,
    this.duration = const Duration(milliseconds: 900),
    this.offset = 50.0,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(offset * (1.0 - value), 0.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
