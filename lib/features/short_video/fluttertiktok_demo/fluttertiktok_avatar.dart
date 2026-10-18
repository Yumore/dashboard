import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_remote_image.dart';
import 'package:flutter/material.dart';

/// Port of the source `TikTokAvatar` in
/// `flutter_tiktok/lib/views/tikTokVideoButtonColumn.dart`.
class FlutterTiktokAvatar extends StatelessWidget {
  const FlutterTiktokAvatar({
    required this.url,
    this.size = FlutterTiktokPalette.avatarSize,
    this.showAddBadge = true,
    this.onTap,
    this.addBadgeKey,
    super.key,
  });

  final String url;
  final double size;
  final bool showAddBadge;
  final VoidCallback? onTap;
  final Key? addBadgeKey;

  @override
  Widget build(BuildContext context) {
    final Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: FlutterTiktokPalette.orange,
        shape: BoxShape.circle,
        border: Border.all(color: FlutterTiktokPalette.white),
      ),
      child: ClipOval(
        child: FlutterTiktokRemoteImage(url: url, width: size, height: size),
      ),
    );

    final Widget content;
    if (showAddBadge) {
      content = SizedBox(
        width: size,
        height: size + 10,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: <Widget>[
            avatar,
            Positioned(
              bottom: 0,
              child: Container(
                key: addBadgeKey,
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: FlutterTiktokPalette.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: FlutterTiktokPalette.white,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      content = avatar;
    }

    return GestureDetector(onTap: onTap, child: content);
  }
}
