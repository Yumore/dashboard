import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_friend.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_friends_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_palette.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_photo.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_theme.dart';

/// State of the FlutterSocialAppUIKit `Friends` tab
/// (source `lib/views/screens/friends.dart:11-70`).
///
/// Each row shows a `Follow` / `Unfollow` button whose `onPressed` is an empty
/// closure in the source; the row itself also has an empty `onTap`. They are
/// kept as visibly dead controls.
class FlutterSocialAppUIKitFriendsPageState
    extends State<FlutterSocialAppUIKitFriendsPage> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FlutterSocialAppUIKitTheme.light(),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            decoration: InputDecoration.collapsed(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          ],
        ),
        body: ListView.separated(
          itemCount: flutterSocialAppUIKitFriends.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: Divider(height: 0.5, thickness: 0.5),
            );
          },
          itemBuilder: (BuildContext context, int index) {
            final FlutterSocialAppUIKitFriend friend =
                flutterSocialAppUIKitFriends[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: FlutterSocialAppUIKitPhoto(
                  source: friend.avatar,
                  width: 50.0,
                  height: 50.0,
                  circle: true,
                ),
                title: Text(friend.name),
                subtitle: Text(friend.status),
                trailing: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: friend.isAccept
                        ? Colors.grey
                        : FlutterSocialAppUIKitPalette.secondary,
                  ),
                  child: Text(
                    friend.isAccept ? 'Unfollow' : 'Follow',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}
