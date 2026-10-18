/// One row of the 微信 tab, ported from the source `Message` model.
///
/// Source: `lib/model/mainframe/message.dart`. The badge fields are kept even
/// though the source list never renders them.
class FlutterWechatFullConversation {
  const FlutterWechatFullConversation({
    required this.id,
    required this.name,
    required this.avatars,
    required this.text,
    required this.createdAt,
    required this.type,
    required this.unreadCount,
    required this.badgeVisible,
    required this.badgeDot,
    required this.messageFree,
  });

  final String id;
  final String name;

  /// Avatar urls of the participants: bunded asset paths or http(s) urls.
  final List<String> avatars;

  final String text;
  final String createdAt;

  /// `0` = deleted by the user, `1` = muted, anything else = normal.
  final String type;

  final int unreadCount;
  final bool badgeVisible;
  final bool badgeDot;

  /// Shows the 消息免打扰 icon in front of the preview text.
  final bool messageFree;

  /// The source hard-codes this timestamp for every row.
  static const String displayTime = '2019/12/01';
}
