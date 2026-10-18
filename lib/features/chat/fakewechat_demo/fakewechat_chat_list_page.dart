import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_list_page_state.dart';
import 'package:flutter/material.dart';

/// Port of the source `MessagePage` (聊天 tab).
///
/// The source builds the chat list inside a draggable bottom sheet whose
/// background reveals the 小程序 panel. The port uses Flutter's current
/// `DraggableScrollableSheet` instead of the source's copied old framework
/// class (`lib/bottom_sheet.dart`).
class FakeWechatChatListPage extends StatefulWidget {
  const FakeWechatChatListPage({super.key});

  @override
  State<FakeWechatChatListPage> createState() => FakeWechatChatListPageState();
}
