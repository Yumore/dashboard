import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feed.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_photo.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user_details_page.dart';
import 'package:flutter/material.dart';

/// Port of the source feed card with a banner (source `lib/widgets/feed_card1.dart`).
class FlutterSocialFeedCard1 extends StatelessWidget {
  const FlutterSocialFeedCard1({required this.feed, super.key});

  final FlutterSocialFeed feed;

  @override
  Widget build(BuildContext context) {
    final userImage = InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FlutterSocialUserDetailsPage(userId: feed.userId),
        ),
      ),
      child: Hero(
        tag: feed.userImage,
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: FlutterSocialPhoto(
            source: feed.userImage,
            width: 40.0,
            height: 40.0,
          ),
        ),
      ),
    );

    final headerDesc = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          feed.userName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          feed.createdAt,
          style: TextStyle(
            color: Colors.grey.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[userImage, headerDesc],
    );

    final descriptionText = SizedBox(
      height: 80.0,
      child: Text(
        feed.description,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w600,
          fontSize: 16.0,
        ),
      ),
    );

    final divider = Divider(color: Colors.grey.withValues(alpha: 0.6));

    final footer = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Icon(Icons.share),
        Row(
          children: <Widget>[
            const Text('256'),
            const SizedBox(width: 3.0),
            const Icon(Icons.chat_bubble_outline),
            const SizedBox(width: 30.0),
            const Text('4k'),
            const SizedBox(width: 3.0),
            const Icon(Icons.favorite_border),
          ],
        ),
      ],
    );

    return SizedBox(
      height: 300.0,
      child: Stack(
        children: <Widget>[
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(14.0),
            child: FlutterSocialPhoto(
              source: feed.bannerImg,
              width: MediaQuery.of(context).size.width,
              height: 150.0,
              borderRadius: BorderRadius.circular(14.0),
              icon: Icons.image_outlined,
            ),
          ),
          Positioned(
            top: 90.0,
            left: 0.0,
            right: 0.0,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Material(
                elevation: 5.0,
                shadowColor: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                child: Container(
                  height: 200.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 0.0,
                      left: 20.0,
                      right: 20.0,
                    ),
                    child: Column(
                      children: <Widget>[
                        header,
                        const SizedBox(height: 10.0),
                        descriptionText,
                        divider,
                        footer,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
