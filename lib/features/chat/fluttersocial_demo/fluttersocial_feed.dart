import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_available_images.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user.dart';

/// Port of the source `Feed` model (source `lib/models/feed.dart:4-13`).
class FlutterSocialFeed {
  const FlutterSocialFeed({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.userName,
    required this.userImage,
    this.description =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum id neque libero. Donec finibus sem viverra.',
    this.bannerImg = FlutterSocialAvailableImages.postBanner,
  });

  final int id;
  final String createdAt;
  final int userId;
  final String userName;
  final String userImage;
  final String description;
  final String bannerImg;
}

/// Port of the source `feeds` list (source `lib/models/feed.dart:15-20`).
///
/// The source's feed screen renders only the first three entries
/// (`lib/views/tabs/feeds.dart:38-50`); the fourth is kept because it is real
/// source data.
final List<FlutterSocialFeed> flutterSocialFeeds = <FlutterSocialFeed>[
  FlutterSocialFeed(
    id: 1,
    createdAt: '19 Aug',
    userId: flutterSocialUsers[0].id,
    userName: flutterSocialUsers[0].name,
    userImage: flutterSocialUsers[0].photo,
  ),
  FlutterSocialFeed(
    id: 2,
    createdAt: '20 Aug',
    userId: flutterSocialUsers[1].id,
    userName: flutterSocialUsers[1].name,
    userImage: flutterSocialUsers[1].photo,
  ),
  FlutterSocialFeed(
    id: 3,
    createdAt: '22 Aug',
    userId: flutterSocialUsers[2].id,
    userName: flutterSocialUsers[2].name,
    userImage: flutterSocialUsers[2].photo,
  ),
  FlutterSocialFeed(
    id: 4,
    createdAt: '1 Sept',
    userId: flutterSocialUsers[3].id,
    userName: flutterSocialUsers[3].name,
    userImage: flutterSocialUsers[3].photo,
  ),
];
