import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_feeds_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_post.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_post_item.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_theme.dart';

/// State of the FlutterSocialAppUIKit `Feeds` tab
/// (source `lib/views/screens/home.dart:11-36`).
class FlutterSocialAppUIKitFeedsPageState
    extends State<FlutterSocialAppUIKitFeedsPage> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FlutterSocialAppUIKitTheme.light(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Feeds'),
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: flutterSocialAppUIKitPosts.length,
          itemBuilder: (BuildContext context, int index) {
            final FlutterSocialAppUIKitPost post =
                flutterSocialAppUIKitPosts[index];
            return FlutterSocialAppUIKitPostItem(post: post);
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          onPressed: () {},
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
