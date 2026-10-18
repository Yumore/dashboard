import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_friend.dart';

/// Port of `Comment` from the source `lib/entities.dart`.
///
/// A non-null [replyer] means the source rendered the comment as
/// `poster: replyer` instead of `poster`.
class FakeWechatComment {
  const FakeWechatComment(this.text, this.poster, {this.replyer});

  final String text;
  final FakeWechatFriend poster;
  final FakeWechatFriend? replyer;
}
