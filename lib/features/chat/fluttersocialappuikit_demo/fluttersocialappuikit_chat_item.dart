import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_conversation_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_photo.dart';

/// One row of the FlutterSocialAppUIKit chat list
/// (source `lib/views/widgets/chat_item.dart`).
///
/// The source is a [StatefulWidget] only so it can push the thread from its
/// `ListTile.onTap`; it holds no state, so the port is a [StatelessWidget].
/// Tapping a row opens the thread exactly like the source — through the root
/// navigator, so the row works from inside the tab shell.
class FlutterSocialAppUIKitChatItem extends StatelessWidget {
  const FlutterSocialAppUIKitChatItem({
    required this.avatar,
    required this.name,
    required this.time,
    required this.message,
    required this.isOnline,
    required this.counter,
    super.key,
  });

  final String avatar;
  final String name;
  final String time;
  final String message;
  final bool isOnline;
  final int counter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Stack(
          children: <Widget>[
            FlutterSocialAppUIKitPhoto(
              source: avatar,
              width: 50.0,
              height: 50.0,
              circle: true,
            ),
            Positioned(
              bottom: 0.0,
              left: 6.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                height: 11.0,
                width: 11.0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.greenAccent : Colors.grey,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    height: 7.0,
                    width: 7.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          name,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(message, overflow: TextOverflow.ellipsis, maxLines: 2),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const SizedBox(height: 10.0),
            Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 11.0,
              ),
            ),
            const SizedBox(height: 5.0),
            if (counter != 0)
              Container(
                padding: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                constraints: const BoxConstraints(
                  minWidth: 11.0,
                  minHeight: 11.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 1.0,
                    left: 5.0,
                    right: 5.0,
                  ),
                  child: Text(
                    '$counter',
                    style: const TextStyle(color: Colors.white, fontSize: 10.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  const FlutterSocialAppUIKitConversationPage(),
            ),
          );
        },
      ),
    );
  }
}
