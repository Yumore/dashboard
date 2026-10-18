import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_feed_page_state.dart';
import 'package:flutter/material.dart';

/// Port of the `PageView.builder` home feed in
/// `flutter_tiktok/lib/pages/homePage.dart`.
class FlutterTiktokFeedPage extends StatefulWidget {
  const FlutterTiktokFeedPage({
    required this.favorites,
    required this.onToggleFavorite,
    required this.onLike,
    required this.onComment,
    required this.onAvatar,
    super.key,
  });

  /// Keyed by feed index, mirroring the source's `Map<int, bool> favoriteMap`.
  final Map<int, bool> favorites;
  final ValueChanged<int> onToggleFavorite;
  final ValueChanged<int> onLike;
  final ValueChanged<int> onComment;
  final VoidCallback onAvatar;

  static const Key pageViewKey = Key('fluttertiktok_feed_page_view');

  @override
  State<FlutterTiktokFeedPage> createState() => FlutterTiktokFeedPageState();
}
