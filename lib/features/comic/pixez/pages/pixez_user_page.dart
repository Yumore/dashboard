import 'package:flutter/material.dart';

import '../controllers/pixez_user_controller.dart';
import 'pixez_user_page_state.dart';

/// User tab: profile header + works/manga/bookmarks.
class PixezUserPage extends StatefulWidget {
  const PixezUserPage({required this.userId, this.controller, super.key});

  final int userId;
  final PixezUserController? controller;

  @override
  PixezUserPageState createState() => PixezUserPageState();
}
