import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_available_images.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_sample_data.dart';

/// One row of the FlutterSocialAppUIKit `Friends` tab
/// (source `lib/util/data.dart:99-106`, the untyped maps of `friends`).
class FlutterSocialAppUIKitFriend {
  const FlutterSocialAppUIKitFriend({
    required this.name,
    required this.avatar,
    required this.status,
    required this.isAccept,
  });

  final String name;
  final String avatar;

  /// Source `status`, the same literal for every row.
  final String status;

  /// Source `isAccept`: when true the row's button reads `Unfollow`, otherwise
  /// `Follow`.
  final bool isAccept;
}

/// Source `friends`: 13 rows (`lib/util/data.dart:99-106`). The source draws
/// names/avatars/`isAccept` from `Random()`; the port resolves each draw to a
/// fixed index (see `fluttersocialappuikit_sample_data.dart`).
final List<FlutterSocialAppUIKitFriend> flutterSocialAppUIKitFriends =
    List<FlutterSocialAppUIKitFriend>.generate(13, (int index) {
      return FlutterSocialAppUIKitFriend(
        name: FlutterSocialAppUIKitSampleData.names[index % 10],
        avatar: FlutterSocialAppUIKitAvailableImages.at(index + 2),
        status: 'Anything could be here',
        isAccept: index.isEven,
      );
    });
