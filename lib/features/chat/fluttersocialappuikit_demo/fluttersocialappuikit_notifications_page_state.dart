import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_notification.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_notifications_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_photo.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_theme.dart';

/// State of the FlutterSocialAppUIKit `Notifications` tab
/// (source `lib/views/screens/notifications.dart:12-54`).
class FlutterSocialAppUIKitNotificationsPageState
    extends State<FlutterSocialAppUIKitNotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FlutterSocialAppUIKitTheme.light(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Notifications'),
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          ],
        ),
        body: ListView.builder(
          itemCount: flutterSocialAppUIKitNotifications.length,
          itemBuilder: (BuildContext context, int index) {
            final FlutterSocialAppUIKitNotification notification =
                flutterSocialAppUIKitNotifications[index];
            return ListTile(
              contentPadding: const EdgeInsets.all(8.0),
              leading: FlutterSocialAppUIKitPhoto(
                source: notification.avatar,
                width: 50.0,
                height: 50.0,
                circle: true,
              ),
              title: Text(notification.text),
              trailing: Text(
                notification.time,
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 11.0,
                ),
              ),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
