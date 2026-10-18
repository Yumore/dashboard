import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_palette.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_photo.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_profile.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_profile_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_theme.dart';

/// State of the FlutterSocialAppUIKit `Profile` tab
/// (source `lib/views/screens/profile.dart:11-140`).
///
/// `Message` and `Add Friend` are empty callbacks in the source, and the
/// gallery tiles have no tap handler; the port keeps both as dead controls.
class FlutterSocialAppUIKitProfilePageState
    extends State<FlutterSocialAppUIKitProfilePage> {
  @override
  Widget build(BuildContext context) {
    final FlutterSocialAppUIKitProfile profile = flutterSocialAppUIKitProfile;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tile = screenWidth / 3.0 - 20.0;

    return Theme(
      data: FlutterSocialAppUIKitTheme.light(),
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Center(
                child: FlutterSocialAppUIKitPhoto(
                  source: profile.avatar,
                  width: 100.0,
                  height: 100.0,
                  circle: true,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Center(
              child: Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                profile.status,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.message),
                      label: const Text('Message'),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: FlutterSocialAppUIKitPalette.secondary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Friend'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildCategory(profile.posts, 'Posts'),
                _buildCategory(profile.friends, 'Friends'),
                _buildCategory(profile.groups, 'Groups'),
              ],
            ),
            const SizedBox(height: 20.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(5.0),
              itemCount: profile.gallery.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: FlutterSocialAppUIKitPhoto(
                    source: profile.gallery[index],
                    width: tile,
                    height: tile,
                    borderRadius: BorderRadius.zero,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String value, String label) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
