import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_available_images.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_sample_data.dart';

/// One card of the FlutterSocialAppUIKit `Feeds` tab
/// (source `lib/util/data.dart:55-62`, the untyped maps of `posts`).
class FlutterSocialAppUIKitPost {
  const FlutterSocialAppUIKitPost({
    required this.name,
    required this.avatar,
    required this.time,
    required this.image,
  });

  final String name;

  /// Source `dp`, the small round author picture.
  final String avatar;
  final String time;

  /// Source `img`, the large picture under the author row.
  final String image;
}

/// Source `posts`: 13 feed cards (`lib/util/data.dart:55-62`). The source draws
/// every field from `Random()`; the port resolves each draw to a fixed index
/// (see `fluttersocialappuikit_sample_data.dart`).
final List<FlutterSocialAppUIKitPost> flutterSocialAppUIKitPosts =
    List<FlutterSocialAppUIKitPost>.generate(13, (int index) {
      return FlutterSocialAppUIKitPost(
        name: FlutterSocialAppUIKitSampleData.names[index % 10],
        avatar: FlutterSocialAppUIKitAvailableImages.at(index),
        time: '${(index * 5) % 50} min ago',
        image: FlutterSocialAppUIKitAvailableImages.at(index + 7),
      );
    });
