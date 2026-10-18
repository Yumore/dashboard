import 'package:flutter/material.dart';

/// `lib/pages/mine/widgets/text_image_wiget.dart` → `TextImageWidget`.
///
/// The source's `space == 0 ? space : 10` meant every non-zero `space`
/// collapsed to `10`; that behaviour is preserved (the parameter cannot widen
/// the gap), because the picture-detail footer's icon rows are spaced by it.
class EyepetizerFlutterTextImageWidget extends StatelessWidget {
  const EyepetizerFlutterTextImageWidget({
    super.key,
    this.icon,
    this.text,
    this.space = 0,
  });

  final IconData? icon;
  final String? text;
  final int space;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon ?? Icons.star, size: 16, color: Colors.white),
        SizedBox(width: space == 0 ? space.toDouble() : 10),
        Text(
          text ?? '',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }
}
