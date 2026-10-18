import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_audio_link.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_comment.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_friend.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_web_page_link.dart';

/// Port of `Moment` from the source `lib/entities.dart`.
///
/// Source types: 1 text, 2 image grid, 3 web-page card, 4 audio card.
class FakeWechatMoment {
  FakeWechatMoment({
    required this.friend,
    required this.type,
    this.text = '',
    this.timestamp,
    this.audioLink,
    this.webPageLink,
    List<String>? images,
    List<FakeWechatFriend>? likes,
    List<FakeWechatComment>? comments,
  }) : images = images ?? <String>[],
       likes = likes ?? <FakeWechatFriend>[],
       comments = comments ?? <FakeWechatComment>[],
       assert(type != 4 || audioLink != null),
       assert(type != 3 || webPageLink != null),
       assert(type != 2 || (images != null && images.isNotEmpty));

  static const int textType = 1;
  static const int imageType = 2;
  static const int webPageType = 3;
  static const int audioType = 4;

  final FakeWechatFriend friend;
  final int type;
  final String text;
  final num? timestamp;
  final FakeWechatAudioLink? audioLink;
  final FakeWechatWebPageLink? webPageLink;
  final List<String> images;
  final List<FakeWechatFriend> likes;
  final List<FakeWechatComment> comments;

  /// Per-page copy used by [FakeWechatMomentsPageState]. The source's
  /// `MomentsModel` mutates the shared seed lists; copying keeps widget tests
  /// independent without changing the seeded values.
  FakeWechatMoment copy() {
    return FakeWechatMoment(
      friend: friend,
      type: type,
      text: text,
      timestamp: timestamp,
      audioLink: audioLink,
      webPageLink: webPageLink,
      images: List<String>.of(images),
      likes: List<FakeWechatFriend>.of(likes),
      comments: List<FakeWechatComment>.of(comments),
    );
  }
}
