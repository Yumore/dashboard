import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_chat_item.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_chat_preview.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_chats_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_palette.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_theme.dart';

/// State of the FlutterSocialAppUIKit `Chats` tab
/// (source `lib/views/screens/chat/chats.dart:13-95`).
class FlutterSocialAppUIKitChatsPageState
    extends State<FlutterSocialAppUIKitChatsPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: FlutterSocialAppUIKitPalette.secondary,
            labelColor: FlutterSocialAppUIKitPalette.secondary,
            unselectedLabelColor: Colors.grey[600],
            tabs: const <Widget>[
              Tab(text: 'Message'),
              Tab(text: 'Groups'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            _buildList(flutterSocialAppUIKitChats),
            _buildList(flutterSocialAppUIKitGroups),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: FlutterSocialAppUIKitPalette.secondary,
          onPressed: () {},
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildList(List<FlutterSocialAppUIKitChatPreview> rows) {
    return ListView.separated(
      padding: const EdgeInsets.all(10.0),
      itemCount: rows.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Divider(height: 0.5, thickness: 0.5),
        );
      },
      itemBuilder: (BuildContext context, int index) {
        final FlutterSocialAppUIKitChatPreview row = rows[index];
        return FlutterSocialAppUIKitChatItem(
          avatar: row.avatar,
          name: row.name,
          time: row.time,
          message: row.message,
          isOnline: row.isOnline,
          counter: row.counter,
        );
      },
    );
  }
}
