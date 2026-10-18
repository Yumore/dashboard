import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_available_images.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_sample_data.dart';

/// One row of the FlutterSocialAppUIKit chat list
/// (source `lib/util/data.dart:64-84`, the untyped maps of `chats`/`groups`).
class FlutterSocialAppUIKitChatPreview {
  const FlutterSocialAppUIKitChatPreview({
    required this.avatar,
    required this.name,
    required this.message,
    required this.counter,
    required this.time,
    required this.isOnline,
  });

  final String avatar;
  final String name;
  final String message;
  final int counter;
  final String time;
  final bool isOnline;
}

/// Source `chats`: 13 rows, the `Message` tab of the chat list
/// (`lib/util/data.dart:64-73`).
///
/// The source draws every field from `Random()`; the port resolves each draw to
/// a fixed index (see `fluttersocialappuikit_sample_data.dart`). The sample
/// names are the first ten of `names`, and the messages the first ten of
/// `messages`, exactly like the source's `nextInt(10)`.
final List<FlutterSocialAppUIKitChatPreview> flutterSocialAppUIKitChats =
    List<FlutterSocialAppUIKitChatPreview>.generate(13, (int index) {
      return FlutterSocialAppUIKitChatPreview(
        avatar: FlutterSocialAppUIKitAvailableImages.at(index * 3),
        name: FlutterSocialAppUIKitSampleData.names[index % 10],
        message: FlutterSocialAppUIKitSampleData.messages[(index + 2) % 10],
        counter: index % 4 == 0 ? index + 1 : 0,
        time: '${(index * 7) % 50} min ago',
        isOnline: index.isEven,
      );
    });

/// Source `groups`: 13 rows, the `Groups` tab of the chat list
/// (`lib/util/data.dart:75-84`). The source names them `Group N` with a random
/// `N` below 20; the port numbers them `Group 1` … `Group 13`.
final List<FlutterSocialAppUIKitChatPreview> flutterSocialAppUIKitGroups =
    List<FlutterSocialAppUIKitChatPreview>.generate(13, (int index) {
      return FlutterSocialAppUIKitChatPreview(
        avatar: FlutterSocialAppUIKitAvailableImages.at(index + 5),
        name: 'Group ${index + 1}',
        message: FlutterSocialAppUIKitSampleData.messages[(index + 4) % 10],
        counter: index % 3 == 0 ? index + 1 : 0,
        time: '${(index * 11) % 50} min ago',
        isOnline: index.isOdd,
      );
    });
