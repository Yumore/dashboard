import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_friend.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_message.dart';

/// Port of `FriendEntrance`/`Entrance<Friend>` from the source
/// `lib/entities.dart` and `lib/data_source.dart`.
class FakeWechatChatEntrance {
  const FakeWechatChatEntrance({
    required this.friend,
    required this.unreadCount,
    required this.recentMessage,
  });

  final FakeWechatFriend friend;
  final int unreadCount;
  final FakeWechatMessage recentMessage;

  String get name => friend.name;
  String? get icon => friend.avatar;
  String get unreadLabel => '$unreadCount';
}
