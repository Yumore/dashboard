import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_available_images.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_sample_data.dart';

/// One row of the FlutterSocialAppUIKit `Notifications` tab
/// (source `lib/util/data.dart:46-53`, the untyped maps of `notifications`).
class FlutterSocialAppUIKitNotification {
  const FlutterSocialAppUIKitNotification({
    required this.name,
    required this.avatar,
    required this.time,
    required this.text,
  });

  final String name;
  final String avatar;
  final String time;

  /// The already-rendered notification sentence, as in the source map's `notif`
  /// field.
  final String text;
}

/// Source `notifications`: 13 rows (`lib/util/data.dart:46-53`). The source
/// draws its names/templates from `Random()`; the port resolves each draw to a
/// fixed index and renders the source's sentence format with
/// `FlutterSocialAppUIKitSampleData.renderNotification`.
final List<FlutterSocialAppUIKitNotification>
flutterSocialAppUIKitNotifications =
    List<FlutterSocialAppUIKitNotification>.generate(13, (int index) {
      final String name = FlutterSocialAppUIKitSampleData.names[index % 10];
      return FlutterSocialAppUIKitNotification(
        name: name,
        avatar: FlutterSocialAppUIKitAvailableImages.at(index + 1),
        time: '${(index * 3) % 50} min ago',
        text: FlutterSocialAppUIKitSampleData.renderNotification(
          FlutterSocialAppUIKitSampleData.notificationTemplates[index % 10],
          name: name,
          count: 12 + index,
        ),
      );
    });
