import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_chat_bubble.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_message.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_photo.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user_details_page.dart';
import 'package:flutter/material.dart';

/// Port of the source chat thread (source `lib/views/chat_details.dart`).
///
/// The source renders the same hard-coded [flutterSocialMessages] thread for
/// whichever conversation is opened, so the port does the same.
///
/// The camera and send buttons keep the source's empty callbacks: they are part
/// of the demo's look and are intentionally inert, not broken features.
class FlutterSocialChatThreadPage extends StatelessWidget {
  const FlutterSocialChatThreadPage({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context) {
    final user = flutterSocialUsers.singleWhere((user) => user.id == userId);

    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final userImage = InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FlutterSocialUserDetailsPage(userId: user.id),
        ),
      ),
      child: Hero(
        tag: user.photo,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 10.0),
          child: FlutterSocialPhoto(
            source: user.photo,
            width: 50.0,
            height: 50.0,
            circle: true,
          ),
        ),
      ),
    );

    final userName = Hero(
      tag: user.name,
      child: Text(
        user.name,
        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );

    final appBar = Material(
      elevation: 5.0,
      shadowColor: Colors.grey,
      child: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            userName,
            userImage,
          ],
        ),
      ),
    );

    final textInput = Container(
      padding: const EdgeInsets.only(left: 10.0),
      height: 47.0,
      width: deviceWidth * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Type a message...',
          hintStyle: TextStyle(
            color: Colors.grey.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    final messageList = ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: flutterSocialMessages.length,
      itemBuilder: (BuildContext context, int index) {
        return FlutterSocialChatBubble(message: flutterSocialMessages[index]);
      },
    );

    final inputBox = Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60.0,
        width: deviceWidth,
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt, color: Colors.grey),
              iconSize: 32.0,
            ),
            textInput,
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.send, color: Colors.grey),
              iconSize: 32.0,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: deviceHeight,
            width: deviceWidth,
            child: Column(
              children: <Widget>[
                appBar,
                const SizedBox(height: 10.0),
                Flexible(child: messageList),
              ],
            ),
          ),
          inputBox,
        ],
      ),
    );
  }
}
