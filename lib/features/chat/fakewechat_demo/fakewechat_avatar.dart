import 'package:flutter/material.dart';

/// Offline stand-in for the source's remote `Image.network` avatars.
///
/// `fake_wechat` bundles no image assets at all: every portrait is a bdstatic
/// / timgsa / duitang URL. Loading those would make the demo depend on the
/// network, so the port renders a deterministic coloured initial instead while
/// keeping the original URL in [FakeWechatFriend.avatar].
class FakeWechatAvatar extends StatelessWidget {
  const FakeWechatAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.borderRadius = 6,
  });

  final String name;
  final double size;
  final double borderRadius;

  static const List<Color> _colors = <Color>[
    Color(0xFF5B8C5A),
    Color(0xFF4A7BA7),
    Color(0xFFB07A45),
    Color(0xFF8E6C9B),
    Color(0xFFB05A5A),
    Color(0xFF4E8C8C),
    Color(0xFF7A7A45),
    Color(0xFF9B6B8E),
  ];

  @override
  Widget build(BuildContext context) {
    final int hash = name.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    final Color color = _colors[hash % _colors.length];
    final String initial = name.isEmpty ? '?' : name.substring(0, 1);

    return Semantics(
      label: name,
      image: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
