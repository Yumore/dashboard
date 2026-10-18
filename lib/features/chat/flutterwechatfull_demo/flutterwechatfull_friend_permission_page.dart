import 'package:flutter/material.dart';

import 'flutterwechatfull_contact.dart';
import 'flutterwechatfull_friend_permission_page_state.dart';

/// The source's `FriendPermissionPage`.
class FlutterWechatFullFriendPermissionPage extends StatefulWidget {
  const FlutterWechatFullFriendPermissionPage({
    required this.contact,
    super.key,
  });

  final FlutterWechatFullContact contact;

  @override
  FlutterWechatFullFriendPermissionPageState createState() =>
      FlutterWechatFullFriendPermissionPageState();
}
