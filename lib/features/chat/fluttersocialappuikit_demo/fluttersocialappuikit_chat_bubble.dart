import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_message_type.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_palette.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_photo.dart';

/// One bubble of the FlutterSocialAppUIKit chat thread
/// (source `lib/views/widgets/chat_bubble.dart`).
///
/// Faithful detail: the source is stateful only to hold a random
/// `Colors.primaries` index for the group-name colour. The port takes that
/// index from the caller ([usernameColorIndex]) so the colour is stable.
///
/// The source compares the string `"text"` against the bubble type and takes
/// the accent from `Theme.of(context).colorScheme.secondary`; the port uses the
/// [FlutterSocialAppUIKitMessageType] enum and the demo palette's pinned accent
/// (the source's light-theme colour).
class FlutterSocialAppUIKitChatBubble extends StatelessWidget {
  const FlutterSocialAppUIKitChatBubble({
    required this.message,
    required this.time,
    required this.isMe,
    required this.isGroup,
    required this.username,
    required this.type,
    required this.replyText,
    required this.isReply,
    required this.replyName,
    this.usernameColorIndex = 0,
    super.key,
  });

  final String message;
  final String time;
  final bool isMe;
  final bool isGroup;
  final String username;
  final FlutterSocialAppUIKitMessageType type;
  final String replyText;
  final bool isReply;
  final String replyName;
  final int usernameColorIndex;

  bool get _isText => type == FlutterSocialAppUIKitMessageType.text;

  Color _chatBubbleColor(BuildContext context) {
    if (isMe) {
      return FlutterSocialAppUIKitPalette.secondary;
    }
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.grey[800]!;
    }
    return Colors.grey[200]!;
  }

  Color _chatBubbleReplyColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.grey[600]!;
    }
    return Colors.grey[50]!;
  }

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment align = isMe
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final BorderRadius radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          );
    final Color? textColor = Theme.of(context).textTheme.titleLarge?.color;
    final double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: _chatBubbleColor(context),
            borderRadius: radius,
          ),
          constraints: BoxConstraints(maxWidth: width / 1.3, minWidth: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (!isMe && isGroup)
                Container(
                  padding: const EdgeInsets.only(right: 48.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    username,
                    style: TextStyle(
                      fontSize: 13.0,
                      color:
                          Colors.primaries[usernameColorIndex %
                              Colors.primaries.length],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              if (!isMe && isGroup) const SizedBox(height: 5.0),
              if (isReply)
                Container(
                  decoration: BoxDecoration(
                    color: _chatBubbleReplyColor(context),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  constraints: const BoxConstraints(
                    minHeight: 25.0,
                    maxHeight: 100.0,
                    minWidth: 80.0,
                  ),
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isMe ? 'You' : replyName,
                          style: const TextStyle(
                            color: FlutterSocialAppUIKitPalette.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          replyText,
                          style: TextStyle(color: textColor, fontSize: 10.0),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 2.0),
              if (isReply) const SizedBox(height: 5.0),
              Padding(
                padding: EdgeInsets.all(_isText ? 5.0 : 0.0),
                child: _isText
                    ? Container(
                        alignment: isReply ? Alignment.centerLeft : null,
                        child: Text(
                          message,
                          style: TextStyle(
                            color: isMe ? Colors.white : textColor,
                          ),
                        ),
                      )
                    : FlutterSocialAppUIKitPhoto(
                        source: message,
                        width: width / 1.3,
                        height: 130.0,
                      ),
              ),
            ],
          ),
        ),
        Padding(
          padding: isMe
              ? const EdgeInsets.only(right: 10.0, bottom: 10.0)
              : const EdgeInsets.only(left: 10.0, bottom: 10.0),
          child: Text(time, style: TextStyle(color: textColor, fontSize: 10.0)),
        ),
      ],
    );
  }
}
