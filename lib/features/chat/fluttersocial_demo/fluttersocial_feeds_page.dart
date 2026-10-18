import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feed.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feed_card1.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feed_card2.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feed_card3.dart';
import 'package:flutter/material.dart';

/// Port of the source feed tab (source `lib/views/tabs/feeds.dart`).
///
/// The source renders only `feeds[0..2]`; the fourth source feed stays in the
/// data but is not shown, exactly as upstream.
class FlutterSocialFeedsPage extends StatelessWidget {
  const FlutterSocialFeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageTitle = Padding(
      padding: const EdgeInsets.only(top: 1.0, bottom: 30.0),
      child: const Text(
        'Feed',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 40.0,
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey.withValues(alpha: 0.1),
          padding: const EdgeInsets.only(top: 40.0),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(
                  top: 30.0,
                  left: 30.0,
                  right: 30.0,
                  bottom: 30.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    pageTitle,
                    FlutterSocialFeedCard1(feed: flutterSocialFeeds[0]),
                    const SizedBox(height: 10.0),
                    FlutterSocialFeedCard2(feed: flutterSocialFeeds[1]),
                    const SizedBox(height: 10.0),
                    FlutterSocialFeedCard3(feed: flutterSocialFeeds[2]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
