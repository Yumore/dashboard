import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// A private message session with another user.
///
/// Ported from `tsdm_client/lib/features/notification/models/message.dart`.
class TsdmPersonalMessage {
  /// Create a private message session.
  const TsdmPersonalMessage({
    required this.user,
    required this.message,
    required this.lastMessageTime,
    required this.count,
    required this.chatUrl,
  });

  /// The other user communicating with.
  final TsdmUser user;

  /// Last message content.
  final String message;

  /// Datetime of the latest message.
  final DateTime lastMessageTime;

  /// Count of messages with the user, null when not shown.
  final int? count;

  /// Chat page url.
  final String chatUrl;

  /// Build from a `dl` node with id `pmlist_XXXX`.
  static TsdmPersonalMessage? fromDl(dom.Element element) {
    if (!element.id.startsWith('pmlist')) {
      return null;
    }
    final messageId = element.id.split('_').elementAtOrNull(1);
    if (messageId == null) {
      return null;
    }

    // Parse N from "共 N 条".
    final count = element
        .q('dd.y.mtm.pm_o > span.xg1')
        ?.text
        .split(' ')
        .elementAtOrNull(1)
        ?.parseToInt();

    final avatarUrl = element.q('dd.m.avt > a > img')?.imageUrl();
    final spaceUrl = element.q('dd.m.avt > a')?.attributes['href'];
    if (avatarUrl == null || spaceUrl == null) {
      return null;
    }

    final contentNode = element.q('dd.ptm.pm_c');
    if (contentNode == null) {
      return null;
    }

    final username = element.q('dd:nth-child(3) > a')?.text;
    final lastMessageTime = element.q('dd:nth-child(3) > span.xg1')?.dateTime();
    final chatUrl = element
        .q('a#pmlist_${messageId}_a')
        ?.attributes['href']
        ?.prependHost();
    final message = element
        .q('dd:nth-child(3) > span.xg1')
        ?.previousNode
        ?.text
        ?.split(':')
        .elementAtOrNull(1)
        ?.trim();
    if (username == null ||
        lastMessageTime == null ||
        chatUrl == null ||
        message == null) {
      return null;
    }

    return TsdmPersonalMessage(
      user: TsdmUser(avatarUrl: avatarUrl, name: username, url: spaceUrl),
      message: message,
      lastMessageTime: lastMessageTime,
      count: count,
      chatUrl: chatUrl,
    );
  }
}

/// A broadcast message received from the system.
///
/// Ported from `tsdm_client/lib/features/notification/models/message.dart`.
class TsdmBroadcastMessage {
  /// Create a broadcast message.
  const TsdmBroadcastMessage({
    required this.message,
    required this.messageTime,
    required this.redirectUrl,
  });

  /// Message content text.
  final String message;

  /// Datetime of the message.
  final DateTime messageTime;

  /// Url to redirect to, usually a thread page; null when the broadcast
  /// message has no corresponding url.
  final String? redirectUrl;

  /// Build from a `dl` node with id `gpmlist_${ID}`.
  static TsdmBroadcastMessage? fromDl(dom.Element element) {
    if (!element.id.startsWith('gpmlist_')) {
      return null;
    }

    final infoNode = element.q('dd:nth-child(3)');
    if (infoNode == null) {
      return null;
    }
    final message = infoNode.q('span')?.text.trim();
    final messageTime = infoNode.q('span.xg1')?.dateTime();
    final redirectUrl = infoNode.q('a')?.attributes['href']?.prependHost();
    if (message == null || messageTime == null) {
      return null;
    }

    return TsdmBroadcastMessage(
      message: message,
      messageTime: messageTime,
      redirectUrl: redirectUrl,
    );
  }
}
