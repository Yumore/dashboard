import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// A thread entry of the `latest thread` page (`mod=forum&srchfrom=...`).
///
/// Ported from `tsdm_client/lib/features/latest_thread/models/latest_thread.dart`.
class TsdmLatestThread {
  const TsdmLatestThread({
    required this.title,
    required this.url,
    required this.threadID,
    required this.forumName,
    required this.forumUrl,
    required this.replyCount,
    required this.viewCount,
    required this.quotedMessage,
    required this.latestReplyAuthor,
    required this.latestReplyTime,
  });

  /// Thread title.
  final String title;

  /// Thread url.
  final String url;

  /// Thread id.
  final String threadID;

  /// Forum name.
  final String forumName;

  /// Forum url.
  final String forumUrl;

  /// Reply count.
  final int replyCount;

  /// View count.
  final int viewCount;

  /// Quoted message of the latest reply.
  final String quotedMessage;

  /// Author of the latest reply.
  final TsdmUser? latestReplyAuthor;

  /// Time of the latest reply.
  final DateTime? latestReplyTime;

  /// Regex extracting the reply and view count from the statistics line.
  static final _countRe = RegExp(r'(?<count>\d+)');

  /// Build from a `<li>` node inside `div#threadlist > ul`.
  ///
  /// Returns null when any field of the entry is missing, as the source does.
  static TsdmLatestThread? fromLi(dom.Element element) {
    final titleNode = element.q('h3 > a');
    final title = titleNode?.firstEndDeepText()?.trim();
    final url = titleNode?.firstHref()?.prependHost();
    final threadID = url?.uriQueryParameter('tid');

    final statisticsText = element.q('p:nth-child(2)')?.firstEndDeepText();
    final matches = _countRe.allMatches(statisticsText ?? '').toList();
    final replyCount = matches.isNotEmpty
        ? matches[0].namedGroup('count')?.parseToInt()
        : null;
    final viewCount = matches.length > 1
        ? matches[1].namedGroup('count')?.parseToInt()
        : null;

    final quotedMessage = element.q('p:nth-child(3)')?.firstEndDeepText();

    final infoNode = element.q('p:nth-child(4)');
    final publishTime = infoNode
        ?.q('span:nth-child(1)')
        ?.firstEndDeepText()
        ?.parseToDateTimeUtc8();
    final username = infoNode?.q('span:nth-child(2) > a')?.firstEndDeepText();
    final userUrl = infoNode
        ?.q('span:nth-child(2) > a')
        ?.firstHref()
        ?.prependHost();
    final forumName = infoNode?.q('span:nth-child(3) > a')?.firstEndDeepText();
    final forumUrl = infoNode
        ?.q('span:nth-child(3) > a')
        ?.firstHref()
        ?.prependHost();

    if (title == null ||
        url == null ||
        threadID == null ||
        replyCount == null ||
        viewCount == null ||
        quotedMessage == null ||
        publishTime == null ||
        username == null ||
        userUrl == null ||
        forumName == null ||
        forumUrl == null) {
      return null;
    }

    return TsdmLatestThread(
      title: title,
      url: url,
      threadID: threadID,
      forumName: forumName,
      forumUrl: forumUrl,
      replyCount: replyCount,
      viewCount: viewCount,
      quotedMessage: quotedMessage,
      latestReplyAuthor: TsdmUser(name: username, url: userUrl),
      latestReplyTime: publishTime,
    );
  }
}
