import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_available_images.dart';

/// The signed-in user of the FlutterSocialAppUIKit `Profile` tab
/// (source `lib/views/screens/profile.dart:26-108`).
class FlutterSocialAppUIKitProfile {
  const FlutterSocialAppUIKitProfile({
    required this.name,
    required this.avatar,
    required this.status,
    required this.posts,
    required this.friends,
    required this.groups,
    required this.gallery,
  });

  final String name;
  final String avatar;

  /// Source literal `Status should be here`.
  final String status;
  final String posts;
  final String friends;
  final String groups;

  /// The 15 pictures of the source's 3-column grid.
  final List<String> gallery;
}

/// Source profile values. The source draws the avatar, the name and the three
/// counters from `Random()` on every build (`lib/views/screens/profile.dart:27,
/// 34, 120`); the port pins them so the static demo is stable and testable.
final FlutterSocialAppUIKitProfile flutterSocialAppUIKitProfile =
    FlutterSocialAppUIKitProfile(
      name: 'Bryant Marley',
      avatar: FlutterSocialAppUIKitAvailableImages.cm4,
      status: 'Status should be here',
      posts: '1234',
      friends: '567',
      groups: '89',
      gallery: List<String>.generate(
        15,
        (int index) => FlutterSocialAppUIKitAvailableImages.at(index * 7),
      ),
    );
