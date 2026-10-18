import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_chat.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_chat_thread_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_palette.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_photo.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user_details_page.dart';
import 'package:flutter/material.dart';

/// Port of the source chats tab, which is also the source's chat list
/// (source `lib/views/tabs/chats.dart`).
class FlutterSocialChatsPage extends StatelessWidget {
  const FlutterSocialChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    final pageTitle = Padding(
      padding: const EdgeInsets.only(top: 1.0, bottom: 20.0),
      child: const Text(
        'Chats',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 40.0,
        ),
      ),
    );

    final searchBar = Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      height: 50.0,
      width: deviceWidth,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      // The source search field has no controller and no filtering logic: it is
      // display-only, and stays that way here.
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          contentPadding: const EdgeInsets.only(top: 15.0),
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: Colors.grey.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    final onlineUsersHeading = Text(
      'ONLINE USERS',
      style: TextStyle(
        color: Colors.grey.withValues(alpha: 0.6),
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
      ),
    );

    final listOfOnlineUsers = SizedBox(
      height: 100.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: flutterSocialUsers
            .map((user) => _buildUserCard(user, context))
            .toList(),
      ),
    );

    final onlineUsers = Container(
      margin: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          onlineUsersHeading,
          const SizedBox(height: 10.0),
          listOfOnlineUsers,
        ],
      ),
    );

    final chatList = SizedBox(
      height: 500.0,
      child: ListView(
        children: flutterSocialChats
            .map((chat) => _buildChatTile(chat, context))
            .toList(),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 40.0),
          width: deviceWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(
                  top: 30.0,
                  left: 30.0,
                  right: 30.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    pageTitle,
                    searchBar,
                    onlineUsers,
                    chatList,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(FlutterSocialUser user, BuildContext context) {
    final firstName = user.name.split(' ')[0];

    final onlineTag = Positioned(
      bottom: 10.0,
      right: 3.0,
      child: Container(
        height: 15.0,
        width: 15.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.0),
          color: Colors.lightGreen,
        ),
      ),
    );

    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => FlutterSocialChatThreadPage(userId: user.id),
            ),
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FlutterSocialPhoto(
                  source: user.photo,
                  width: 70.0,
                  height: 70.0,
                  circle: true,
                ),
              ),
              onlineTag,
            ],
          ),
        ),
        Text(firstName, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildChatTile(FlutterSocialChat chat, BuildContext context) {
    final unreadCount = Positioned(
      bottom: 9.0,
      right: 0.0,
      child: Container(
        height: 25.0,
        width: 25.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.0),
          gradient: FlutterSocialPalette.primaryGradient,
        ),
        child: Center(
          child: Text(
            chat.unreadCount.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );

    final userImage = InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FlutterSocialUserDetailsPage(userId: chat.userId),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Hero(
            tag: chat.userImage,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 10.0),
              child: FlutterSocialPhoto(
                source: chat.userImage,
                width: 70.0,
                height: 70.0,
                circle: true,
              ),
            ),
          ),
          if (chat.unreadCount != 0) unreadCount,
        ],
      ),
    );

    final userNameMessage = Expanded(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FlutterSocialChatThreadPage(userId: chat.userId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: chat.userName,
                child: Text(
                  chat.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
              Text(
                chat.message,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                  color: Colors.grey.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Row(children: <Widget>[userImage, userNameMessage]),
    );
  }
}
