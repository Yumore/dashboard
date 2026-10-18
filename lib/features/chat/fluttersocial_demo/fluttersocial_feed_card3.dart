import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feed.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_photo.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user_details_page.dart';
import 'package:flutter/material.dart';

/// Port of the source feed card with the portrait on the right
/// (source `lib/widgets/feed_card3.dart`).
class FlutterSocialFeedCard3 extends StatelessWidget {
  const FlutterSocialFeedCard3({required this.feed, super.key});

  final FlutterSocialFeed feed;

  @override
  Widget build(BuildContext context) {
    final userImage = Positioned(
      right: 0,
      top: 15.0,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FlutterSocialUserDetailsPage(userId: feed.userId),
          ),
        ),
        child: Hero(
          tag: feed.userImage,
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(14.0),
            child: FlutterSocialPhoto(
              source: feed.userImage,
              width: 120.0,
              height: 120.0,
              borderRadius: BorderRadius.circular(14.0),
              icon: Icons.person_outline,
            ),
          ),
        ),
      ),
    );

    final postDate = Text(
      feed.createdAt,
      style: TextStyle(
        color: Colors.grey.withValues(alpha: 0.6),
        fontWeight: FontWeight.bold,
      ),
    );

    final userName = Text(
      feed.userName,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
    );

    final descriptionText = SizedBox(
      height: 80.0,
      child: Text(
        feed.description,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
      ),
    );

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        postDate,
        userName,
        const SizedBox(height: 5.0),
        descriptionText,
      ],
    );

    return SizedBox(
      height: 150.0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(14.0),
              child: Container(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  right: 100.0,
                  left: 20.0,
                ),
                height: 150.0,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: cardContent,
              ),
            ),
          ),
          userImage,
        ],
      ),
    );
  }
}
