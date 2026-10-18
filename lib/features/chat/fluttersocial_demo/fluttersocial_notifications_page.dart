import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_available_images.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_photo.dart';
import 'package:flutter/material.dart';

/// Port of the source notifications tab (source `lib/views/tabs/notifications.dart`).
///
/// The source has no notification list at all — only this empty state — so the
/// port adds no data structure for one.
class FlutterSocialNotificationsPage extends StatelessWidget {
  const FlutterSocialNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final pageTitle = Padding(
      padding: const EdgeInsets.only(top: 1.0, bottom: 30.0),
      child: const Text(
        'Notifications',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 40.0,
        ),
      ),
    );

    final image = const FlutterSocialPhoto(
      source: FlutterSocialAvailableImages.emptyState,
      width: 200.0,
      height: 200.0,
      borderRadius: BorderRadius.zero,
      icon: Icons.notifications_none,
    );

    final notificationHeader = Container(
      padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
      child: const Text(
        'No New Notification',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
      ),
    );

    final notificationText = Text(
      'You currently do not have any unread notifications.',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
        color: Colors.grey.withValues(alpha: 0.6),
      ),
      textAlign: TextAlign.center,
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
            top: 70.0,
            left: 30.0,
            right: 30.0,
            bottom: 30.0,
          ),
          constraints: BoxConstraints(minHeight: deviceHeight),
          width: deviceWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              pageTitle,
              SizedBox(height: deviceHeight * 0.1),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[image, notificationHeader, notificationText],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
