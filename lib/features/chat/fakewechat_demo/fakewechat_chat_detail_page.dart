import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_ai.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_detail_page_state.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_conversation_model.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_friend.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/page/wechat/chat_detail_page.dart`.
///
/// The AI reply source is injectable so the demo test can replace the 10 second
/// loop with a deterministic one without touching production behaviour.
class FakeWechatChatDetailPage extends StatefulWidget {
  const FakeWechatChatDetailPage({
    super.key,
    required this.friend,
    this.ai,
    this.conversation,
  });

  final FakeWechatFriend friend;
  final FakeWechatChatAi? ai;
  final FakeWechatConversationModel? conversation;

  @override
  State<FakeWechatChatDetailPage> createState() =>
      FakeWechatChatDetailPageState();
}
