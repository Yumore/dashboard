import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_photo.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_post.dart';

/// One card of the FlutterSocialAppUIKit `Feeds` tab
/// (source `lib/views/widgets/post_item.dart`).
///
/// The source's `InkWell.onTap` is an empty closure: the card looks tappable
/// but does nothing. That is kept — it is a dead control of the demo, not a
/// feature waiting to be invented.
class FlutterSocialAppUIKitPostItem extends StatelessWidget {
  const FlutterSocialAppUIKitPostItem({required this.post, super.key});

  final FlutterSocialAppUIKitPost post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: InkWell(
        onTap: () {},
        child: Column(
          children: <Widget>[
            ListTile(
              leading: FlutterSocialAppUIKitPhoto(
                source: post.avatar,
                width: 40.0,
                height: 40.0,
                circle: true,
              ),
              contentPadding: EdgeInsets.zero,
              title: Text(
                post.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                post.time,
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 11.0,
                ),
              ),
            ),
            FlutterSocialAppUIKitPhoto(
              source: post.image,
              width: MediaQuery.of(context).size.width,
              height: 170.0,
            ),
          ],
        ),
      ),
    );
  }
}
