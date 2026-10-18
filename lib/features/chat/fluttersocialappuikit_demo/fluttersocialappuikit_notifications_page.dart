import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_notifications_page_state.dart';

/// `Notifications` tab of the FlutterSocialAppUIKit demo
/// (source `lib/views/screens/notifications.dart:10`).
///
/// The source draws its thirteen rows from `Random()` and gives every row an
/// empty `onTap`; the port renders the resolved rows (see
/// `fluttersocialappuikit_notification.dart`) and keeps the dead row taps.
class FlutterSocialAppUIKitNotificationsPage extends StatefulWidget {
  const FlutterSocialAppUIKitNotificationsPage({super.key});

  @override
  State<FlutterSocialAppUIKitNotificationsPage> createState() =>
      FlutterSocialAppUIKitNotificationsPageState();
}
