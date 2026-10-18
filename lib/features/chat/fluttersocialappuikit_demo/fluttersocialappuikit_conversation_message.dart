import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_available_images.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_message_type.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_sample_data.dart';

/// One bubble of the FlutterSocialAppUIKit chat thread
/// (source `lib/util/data.dart:87-97`, the untyped maps of `conversation`).
class FlutterSocialAppUIKitConversationMessage {
  const FlutterSocialAppUIKitConversationMessage({
    required this.username,
    required this.time,
    required this.type,
    required this.replyText,
    required this.isMe,
    required this.isGroup,
    required this.isReply,
    required this.message,
  });

  /// Group label the bubble would print when [isGroup] is true. The source's
  /// synthetic conversation always has `isGroup: false`, so it is never shown.
  final String username;
  final String time;
  final FlutterSocialAppUIKitMessageType type;

  /// Quoted text of a reply bubble.
  final String replyText;
  final bool isMe;
  final bool isGroup;
  final bool isReply;

  /// Text of a text bubble, or the asset path of an image bubble.
  ///
  /// The source resolves this in the widget builder
  /// (`lib/views/screens/chat/conversation.dart:86-88`); the port resolves the
  /// same choice once in the data so the demo is stable.
  final String message;
}

/// Source `conversation`: the ten bubbles every chat thread shows
/// (`lib/util/data.dart:87-97`). The source draws each field from `Random()`;
/// the port resolves each draw to a fixed index, keeping the source's
/// alternating text/image mix, its `isMe`/`isReply` mix and its always-false
/// `isGroup`.
final List<FlutterSocialAppUIKitConversationMessage>
flutterSocialAppUIKitConversation =
    List<FlutterSocialAppUIKitConversationMessage>.generate(10, (int index) {
      final FlutterSocialAppUIKitMessageType type = index.isEven
          ? FlutterSocialAppUIKitMessageType.text
          : FlutterSocialAppUIKitMessageType.image;
      return FlutterSocialAppUIKitConversationMessage(
        username: 'Group ${index % 20}',
        time: '${(index * 9) % 50} min ago',
        type: type,
        replyText: FlutterSocialAppUIKitSampleData.messages[(index + 1) % 10],
        isMe: index.isOdd,
        isGroup: false,
        isReply: index % 3 == 1,
        message: type == FlutterSocialAppUIKitMessageType.text
            ? FlutterSocialAppUIKitSampleData.messages[index % 10]
            : FlutterSocialAppUIKitAvailableImages.at(index + 1),
      );
    });
