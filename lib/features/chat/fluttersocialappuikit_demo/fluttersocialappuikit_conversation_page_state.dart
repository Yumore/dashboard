import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_available_images.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_chat_bubble.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_conversation_message.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_conversation_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_palette.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_photo.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_sample_data.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_theme.dart';

/// State of the FlutterSocialAppUIKit chat thread
/// (source `lib/views/screens/chat/conversation.dart:14-105`).
///
/// Faithful detail: the source draws the participant name and avatar from
/// `Random()` every time the screen opens; the port pins them so the static
/// demo does not change under the reader (and so it can be asserted).
class FlutterSocialAppUIKitConversationPageState
    extends State<FlutterSocialAppUIKitConversationPage> {
  final String _name = FlutterSocialAppUIKitSampleData.names[0];
  final String _avatar = FlutterSocialAppUIKitAvailableImages.cm2;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FlutterSocialAppUIKitTheme.light(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 3.0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.keyboard_backspace),
          ),
          titleSpacing: 0.0,
          title: InkWell(
            onTap: () {},
            child: Row(
              children: <Widget>[
                FlutterSocialAppUIKitPhoto(
                  source: _avatar,
                  width: 40.0,
                  height: 40.0,
                  circle: true,
                ),
                const SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
          ],
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                itemCount: flutterSocialAppUIKitConversation.length,
                reverse: true,
                itemBuilder: (BuildContext context, int index) {
                  final FlutterSocialAppUIKitConversationMessage message =
                      flutterSocialAppUIKitConversation[index];
                  return FlutterSocialAppUIKitChatBubble(
                    message: message.message,
                    time: message.time,
                    username: message.username,
                    type: message.type,
                    replyText: message.replyText,
                    isMe: message.isMe,
                    isGroup: message.isGroup,
                    isReply: message.isReply,
                    replyName: _name,
                    usernameColorIndex: index,
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 10.0,
          color: FlutterSocialAppUIKitPalette.lightPrimary,
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.add,
                  color: FlutterSocialAppUIKitPalette.secondary,
                ),
              ),
              Expanded(
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Write your message...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.mic,
                  color: FlutterSocialAppUIKitPalette.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
