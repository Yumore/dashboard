import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Different notice types.
///
/// Ported from `tsdm_client/lib/features/notification/models/notice.dart`.
enum TsdmNoticeType {
  /// Another user replied to the current user's thread or post.
  reply,

  /// Another user rated the current user's thread or post.
  rate,

  /// Another user rated the current user's thread or post using a batch task.
  batchRate,

  /// Another user mentioned the current user in a post.
  mention,

  /// Another user invited the current user to take part in a thread.
  invite,

  /// Another user became a friend of the current user.
  newFriend,
}

/// A single notice of the current user.
///
/// Ported from `tsdm_client/lib/features/notification/models/notice.dart`.
class TsdmNotice {
  /// Create a notice.
  const TsdmNotice({
    required this.userAvatarUrl,
    required this.username,
    required this.userSpaceUrl,
    required this.noticeTime,
    required this.noticeTimeString,
    required this.noticeThreadUrl,
    required this.noticeThreadTitle,
    required this.redirectUrl,
    required this.ignoreCount,
    required this.noticeType,
    required this.score,
    required this.quotedMessage,
    required this.taskId,
  });

  /// Avatar of the user who triggered this notice.
  final String? userAvatarUrl;

  /// Username of the user who triggered this notice.
  final String? username;

  /// Link to that user's space.
  final String? userSpaceUrl;

  /// Parsed notice time.
  final DateTime? noticeTime;

  /// String format notice time.
  final String noticeTimeString;

  /// Url of the thread that contains this notice's reply.
  final String? noticeThreadUrl;

  /// Title of that thread.
  final String? noticeThreadTitle;

  /// Url that redirects to the related post in the thread.
  final String? redirectUrl;

  /// Number of ignored same notices, null when there is none.
  final int? ignoreCount;

  /// Type of this notice.
  final TsdmNoticeType noticeType;

  /// Score received.
  final String? score;

  /// Comment left when scoring.
  final String? quotedMessage;

  /// Task id of a batch operation, only useful for [TsdmNoticeType.batchRate].
  final String? taskId;

  /// Build from `div#ct > div.mn > div.bm.bw0 > div.xld.xlda > div.nts > div.cl`.
  static TsdmNotice? fromClNode(dom.Element element) {
    final userAvatarUrl = element.q('dd.avt > a > img')?.imageUrl();
    var userSpaceUrl = element.q('dd.avt > a')?.firstHref()?.prependHost();

    final noticeNode = element.q('dt > span > span');
    final noticeTime = noticeNode?.attributes['title']?.parseToDateTimeUtc8();
    final noticeTimeString = noticeNode?.firstEndDeepText();

    String? score;
    String? quotedMessage;
    String? taskId;

    final quoteNode = element.q('dd.ntc_body > div.quote');
    final mentionNode = element.q('dd.ntc_body > blockquote');
    final litNode = element.q('dd.ntc_body > a.lit');
    late final TsdmNoticeType noticeType;
    if (quoteNode != null) {
      noticeType = TsdmNoticeType.rate;
      final n = element.q('dd.ntc_body');
      score = _lastNonEmptyText(n)?.replaceFirst('评分 ', '');
      quotedMessage = quoteNode.text;
    } else if (mentionNode != null) {
      noticeType = TsdmNoticeType.mention;
    } else if (litNode?.attributes['href']?.contains('&tid=') ?? false) {
      noticeType = TsdmNoticeType.invite;
    } else if (element.qAll('dd.ntc_body > a').length == 1) {
      noticeType = TsdmNoticeType.newFriend;
    } else if (element
            .qAll('dd.ntc_body > b')
            .lastOrNull
            ?.text
            .contains('任务ID') ??
        false) {
      noticeType = TsdmNoticeType.batchRate;
    } else {
      noticeType = TsdmNoticeType.reply;
    }

    String? username;
    String? noticeThreadUrl;
    String? noticeThreadTitle;
    String? redirectUrl;

    final a1Node = element.q('dd.ntc_body > a:nth-child(1)');
    final a2Node = element.q('dd.ntc_body > a:nth-child(2)');
    if (noticeType == TsdmNoticeType.reply ||
        noticeType == TsdmNoticeType.invite) {
      username = a1Node?.firstEndDeepText();
      noticeThreadUrl = a2Node?.firstHref();
      noticeThreadTitle = a2Node?.firstEndDeepText();
      redirectUrl = element
          .q('dd.ntc_body > a:nth-child(3)')
          ?.firstHref()
          ?.prependHost();
    } else if (noticeType == TsdmNoticeType.mention) {
      final n = element.q('dd.ntc_body')?.nodes.firstOrNull?.text?.trim();
      const usernameBeginOffset = 3;
      final usernameEndOffset = n?.indexOf('邀请');
      username =
          usernameEndOffset == null || usernameEndOffset < usernameBeginOffset
          ? ''
          : n?.substring(usernameBeginOffset, usernameEndOffset);
      redirectUrl = a1Node?.firstHref()?.prependHost();
      quotedMessage = mentionNode?.firstEndDeepText()?.trim();
    } else if (noticeType == TsdmNoticeType.newFriend) {
      username = a1Node?.firstEndDeepText();
      userSpaceUrl = a1Node?.attributes['href'];
    } else if (noticeType == TsdmNoticeType.batchRate) {
      noticeThreadTitle = a1Node?.firstEndDeepText();
      redirectUrl = a1Node?.firstHref()?.prependHost();
      // `:last-of-type` is not supported by the html package, so the source
      // assumes the user node is always the 5th child; keep that assumption.
      final a3Node = element.q('dd.ntc_body > a:nth-child(5)');
      userSpaceUrl = a3Node?.firstHref();
      username = a3Node?.firstEndDeepText();
      final n = element.q('dd.ntc_body');
      score = _lastTextWhere(
        n,
        (text) => text.startsWith('评分 '),
      )?.replaceFirst('评分 ', '');
      taskId = n?.nodes.lastOrNull?.text?.trim();
      final bList = n?.qAll('b');
      if (bList != null && bList.length == 3) {
        quotedMessage = bList.elementAt(1).nextNode?.text;
      }
    } else {
      noticeThreadTitle = a1Node?.firstEndDeepText();
      redirectUrl = a1Node?.firstHref()?.prependHost();
      userSpaceUrl = a2Node?.firstHref();
      username = a2Node?.firstEndDeepText();
    }

    final ignoreCount = element
        .q('dd.xg1.xw0')
        ?.firstEndDeepText()
        ?.split(' ')
        .elementAtOrNull(1)
        ?.parseToInt();

    if (noticeType == TsdmNoticeType.mention) {
      if (username == null || userSpaceUrl == null || redirectUrl == null) {
        return null;
      }
    } else if (noticeType == TsdmNoticeType.newFriend) {
      if (username == null || userSpaceUrl == null) {
        return null;
      }
    } else if (noticeType == TsdmNoticeType.batchRate) {
      if (username == null || userSpaceUrl == null || taskId == null) {
        return null;
      }
    } else if (username == null ||
        userSpaceUrl == null ||
        noticeTime == null ||
        noticeThreadTitle == null ||
        redirectUrl == null) {
      return null;
    }

    return TsdmNotice(
      userAvatarUrl: userAvatarUrl,
      noticeTime: noticeTime,
      noticeTimeString: noticeTimeString ?? '',
      userSpaceUrl: userSpaceUrl,
      username: username,
      noticeThreadUrl: noticeThreadUrl,
      noticeThreadTitle: noticeThreadTitle,
      redirectUrl: redirectUrl,
      ignoreCount: ignoreCount,
      noticeType: noticeType,
      score: score,
      quotedMessage: quotedMessage,
      taskId: taskId,
    );
  }

  /// Last text node with non-whitespace content inside [node].
  static String? _lastNonEmptyText(dom.Element? node) {
    final nodes = node?.nodes;
    if (nodes == null) {
      return null;
    }
    for (var i = nodes.length - 1; i >= 0; i--) {
      final text = nodes[i].text?.trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  /// Index of the last non-empty text node matching [test].
  static String? _lastTextWhere(
    dom.Element? node,
    bool Function(String text) test,
  ) {
    final nodes = node?.nodes;
    if (nodes == null) {
      return null;
    }
    for (var i = nodes.length - 1; i >= 0; i--) {
      final text = nodes[i].text?.trim();
      if (text != null && text.isNotEmpty && test(text)) {
        return text;
      }
    }
    return null;
  }
}

/// Parse the notice list of a notice page.
///
/// The source read the node list from
/// `div#ct > div.mn > div.bm.bw0 > div.xld.xlda > div.nts > div.cl`.
List<TsdmNotice> parseTsdmNoticeList(dom.Document document) {
  final result = <TsdmNotice>[];
  for (final element in document.qAll(
    'div#ct > div.mn > div.bm.bw0 > div.xld.xlda > div.nts > div.cl',
  )) {
    final notice = TsdmNotice.fromClNode(element);
    if (notice != null) {
      result.add(notice);
    }
  }
  return result;
}
