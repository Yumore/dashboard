import 'package:dashboard/features/anime/tsdm/tsdm_css_types.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_type.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user.dart';
import 'package:html/dom.dart' as dom;

import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_css_parser.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// A normal thread entry in a forum list.
///
/// Ported from `tsdm_client/lib/shared/models/normal_thread.dart`
/// (`NormalThread.fromTBody`).
class TsdmNormalThread {
  const TsdmNormalThread({
    required this.title,
    required this.url,
    required this.threadID,
    required this.author,
    required this.publishDate,
    required this.latestReplyAuthor,
    required this.latestReplyTime,
    required this.iconUrl,
    required this.threadType,
    required this.replyCount,
    required this.viewCount,
    required this.price,
    required this.privilege,
    required this.css,
    required this.stateSet,
    required this.isRecentThread,
  });

  /// Thread title.
  final String title;

  /// Thread url.
  final String url;

  /// Thread id, the `tid` query parameter of [url].
  final String threadID;

  /// Thread author.
  final TsdmUser author;

  /// Thread publish date.
  final DateTime? publishDate;

  /// Author of the latest reply, the thread author when there is no reply.
  final TsdmUser latestReplyAuthor;

  /// Time of the latest reply.
  final DateTime? latestReplyTime;

  /// Icon url of this thread.
  final String iconUrl;

  /// Thread type, `动漫音乐`, `其他`...
  final TsdmThreadType? threadType;

  /// Reply count, `>= 0`.
  final int replyCount;

  /// View count, `>= 0`.
  final int viewCount;

  /// Thread price, may be null.
  final int? price;

  /// Required read privilege, may be null.
  final int? privilege;

  /// Css decoration on the thread entry.
  final TsdmCssTypes? css;

  /// All states of this thread entry.
  final Set<TsdmThreadState> stateSet;

  /// Whether the thread was published within the recent 24 hours.
  final bool isRecentThread;

  /// Build a thread entry from a `<tbody class="tsdm_normalthread">` node.
  ///
  /// Returns null when a required field (icon, title, author, publish time,
  /// last reply author/time or tid) is missing, as the source does.
  static TsdmNormalThread? fromTBody(dom.Element threadElement) {
    final threadIconNode = threadElement.q('tr > td > a > img');
    final threadIconUrl = threadIconNode?.attributes['src']?.prependHost();
    if (threadIconUrl == null) {
      return null;
    }

    final threadTypeNode = threadElement.q('tr > th > em > a:nth-child(1)');
    final threadTypeUrl = threadTypeNode?.attributes['href'];
    final threadTypeName = threadTypeNode?.firstEndDeepText();

    final threadUrlNode = threadElement.q('tr > th > span > a');
    final threadUrl = threadUrlNode?.attributes['href'];
    final threadTitle = threadUrlNode?.firstEndDeepText()?.trim();
    final css = parseTsdmCssString(threadUrlNode?.attributes['style'] ?? '');
    if (threadUrl == null || threadTitle == null) {
      return null;
    }

    int? threadPrice;
    int? privilege;
    for (final node in threadElement.qAll('tr > th > span.xw1')) {
      final prevText = node.previousNode?.text;
      if (prevText == null) {
        continue;
      }
      if (prevText.contains('售价')) {
        threadPrice = node.firstEndDeepText()?.trim().parseToInt();
      } else if (prevText.contains('阅读权限')) {
        privilege = node.firstEndDeepText()?.trim().parseToInt();
      }
    }

    // Two <td class="by"> nodes: the thread author first, the last reply
    // author second.
    final threadAuthorNode = threadElement.q('tr > td.by');
    final threadAuthorUrl = threadAuthorNode?.q('cite > a')?.attributes['href'];
    final threadAuthorUid = threadAuthorUrl?.split('uid=').elementAtOrNull(1);
    final threadAuthorName = threadAuthorNode
        ?.q('cite > a')
        ?.firstEndDeepText()
        ?.trim();
    final threadPublishDate = threadAuthorNode
        ?.q('em > span')
        ?.firstEndDeepText()
        ?.trim()
        .parseToDateTimeUtc8();

    final isRecentThread =
        threadAuthorNode?.q('em > span')?.classes.contains('xi1') ?? false;

    if (threadAuthorUrl == null ||
        threadAuthorName == null ||
        threadPublishDate == null) {
      return null;
    }

    final threadStatisticsNode = threadElement.q('tr > td.num');
    final threadReplyCount = threadStatisticsNode
        ?.q('a.xi2')
        ?.firstEndDeepText()
        ?.parseToInt();
    final threadViewCount = threadStatisticsNode
        ?.q('em')
        ?.firstEndDeepText()
        ?.parseToInt();

    final threadLastReplyNode = threadElement.qAll('tr > td.by').lastOrNull;
    final threadLastReplyAuthorUrl = threadLastReplyNode
        ?.q('cite > a')
        ?.attributes['href'];
    final threadLastReplyAuthorName = threadLastReplyNode
        ?.q('cite > a')
        ?.firstEndDeepText();
    final threadLastReplyTime = threadLastReplyNode?.q('em > a')?.dateTime();

    if (threadLastReplyAuthorName == null ||
        threadLastReplyAuthorUrl == null ||
        threadLastReplyTime == null) {
      return null;
    }

    final threadID = threadUrl.uriQueryParameter('tid');
    if (threadID == null) {
      return null;
    }

    final stateTrNode = threadElement.q('tr');
    final stateSet = <TsdmThreadState>{};
    if (stateTrNode != null) {
      stateSet.addAll(buildThreadStateSetFromTr(stateTrNode));
    }

    return TsdmNormalThread(
      title: threadTitle,
      url: threadUrl,
      threadID: threadID,
      author: TsdmUser(
        name: threadAuthorName,
        uid: threadAuthorUid,
        url: threadAuthorUrl,
      ),
      publishDate: threadPublishDate,
      latestReplyAuthor: TsdmUser(
        name: threadLastReplyAuthorName,
        url: threadLastReplyAuthorUrl,
      ),
      latestReplyTime: threadLastReplyTime,
      iconUrl: threadIconUrl,
      threadType: TsdmThreadType.parse(threadTypeName, threadTypeUrl),
      replyCount: threadReplyCount ?? 0,
      viewCount: threadViewCount ?? 0,
      price: threadPrice,
      privilege: privilege,
      css: css,
      stateSet: stateSet,
      isRecentThread: isRecentThread,
    );
  }

  /// Build the states of a thread from its `<tr>` node.
  ///
  /// Collects the states of the leading icon node and of every `<img>` node
  /// following the thread title.
  static Set<TsdmThreadState> buildThreadStateSetFromTr(
    dom.Element threadElement,
  ) {
    final stateSet = <TsdmThreadState>{};

    final threadIconNode = threadElement.q('td > a > img');
    if (threadIconNode != null) {
      stateSet.addAll(
        TsdmThreadState.parseFromImageNode(
          tagNameUpper: threadIconNode.localName ?? '',
          src: threadIconNode.attributes['src'],
          alt: threadIconNode.attributes['alt'],
        ),
      );
    }

    for (final e in threadElement.qAll('th > img')) {
      stateSet.addAll(
        TsdmThreadState.parseFromImageNode(
          tagNameUpper: e.localName ?? '',
          src: e.attributes['src'],
          alt: e.attributes['alt'],
        ),
      );
    }

    return stateSet;
  }
}
