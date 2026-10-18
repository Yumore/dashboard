import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_friend.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_marker.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_message.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_seed_data.dart';
import 'package:flutter/widgets.dart';

/// State holder for one conversation, replacing the source `ChatModel`
/// (`ViewModelProvider` based).
///
/// The append rules mirror `lib/page/wechat/chat_detail_page.dart`:
/// * outgoing text -> time [FakeWechatMarker] first, then the user message;
/// * AI reply -> only the friend message (the source callback never adds a
///   marker);
/// * outgoing image -> only the image message.
class FakeWechatConversationModel {
  FakeWechatConversationModel({
    required this.friend,
    DateTime Function()? now,
    List<Object>? initialItems,
  }) : _now = now ?? DateTime.now,
       _items = <Object>[...?initialItems];

  final FakeWechatFriend friend;
  final DateTime Function() _now;
  final List<Object> _items;
  final ScrollController scrollController = ScrollController();

  List<Object> get items => List<Object>.unmodifiable(_items);

  List<FakeWechatMessage> get messages =>
      _items.whereType<FakeWechatMessage>().toList(growable: false);

  int get messageCount => messages.length;

  FakeWechatMarker addTimeMarker() {
    final marker = FakeWechatMarker(
      FakeWechatMarker.timeType,
      _now().toString(),
    );
    _items.add(marker);
    return marker;
  }

  FakeWechatMessage appendOutgoingText(String text) {
    final message = FakeWechatMessage(
      type: FakeWechatMessage.textType,
      text: text,
      sender: FakeWechatSeedData.user,
    );
    _items.add(message);
    return message;
  }

  /// Adds the marker and text message in source order. Returns both so tests
  /// can assert the exact append sequence.
  List<Object> sendText(String text) {
    final marker = addTimeMarker();
    final message = appendOutgoingText(text);
    return <Object>[marker, message];
  }

  FakeWechatMessage appendReply(String text, {FakeWechatFriend? sender}) {
    final message = FakeWechatMessage(
      type: FakeWechatMessage.textType,
      text: text,
      sender: sender ?? FakeWechatSeedData.friends[0],
    );
    _items.add(message);
    return message;
  }

  FakeWechatMessage appendOutgoingImage(String path) {
    final message = FakeWechatMessage(
      type: FakeWechatMessage.imageType,
      filePath: path,
      sender: FakeWechatSeedData.user,
    );
    _items.add(message);
    return message;
  }

  bool removeItem(Object item) => _items.remove(item);

  void dispose() {
    scrollController.dispose();
  }
}
