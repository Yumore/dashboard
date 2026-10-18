import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_group.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Build the forum group list of a forum home page / group page.
///
/// Ported from `tsdm_client/lib/features/forum/utils/group.dart`.
class TsdmForumGroupParser {
  const TsdmForumGroupParser._();

  /// Build all groups from [document].
  ///
  /// Recognizes both the style with a user avatar and the style without one.
  static List<TsdmForumGroup> buildGroupListFromDocument(
    dom.Document document,
  ) {
    final forumGroupNodeList = <dom.Element>[
      ...document.qAll('div#ct > div.mn > div.fl.bm > div.bm.bmw.cl'),
      ...document.qAll('div.mn.miku > div.forumlist > div.forumbox'),
    ];
    return forumGroupNodeList.map(buildFromBmNode).toList();
  }

  /// Build a group from a `<div class="bm bmw flg cl">` or `<div class="forumbox">`.
  static TsdmForumGroup buildFromBmNode(dom.Element element) {
    final titleNode =
        element.q('div:nth-child(1) > h2') ??
        // Style 5
        element.q('div.title_r > h2 > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.attributes['href'];

    final forumList = <TsdmForum>[];
    for (final subForumNode in element.qAll(
      'div:nth-child(2) > table > tbody > tr',
    )) {
      // Invisible elements in the web page have no children, skip them.
      if (subForumNode.children.isEmpty) {
        continue;
      }

      // Expanded layout forum.
      if (subForumNode.q('h2') != null) {
        forumList.add(buildExpandedForum(subForumNode));
        continue;
      }

      // A normal layout forum has `class="fl_g"` cells.
      final forumFlGNodeList = subForumNode.qAll('td.fl_g').toList();
      if (forumFlGNodeList.isEmpty) {
        continue;
      }
      forumList.addAll(forumFlGNodeList.map(buildCollapsedForum));
    }

    return TsdmForumGroup(
      name: name ?? '',
      url: url ?? '',
      forumList: forumList,
    );
  }

  /// Build an expanded forum from a `<tr class="fl_row">` node.
  ///
  /// The source is `Forum.fromFlRowNode`.
  static TsdmForum buildExpandedForum(dom.Element element) {
    final titleNode =
        element.q('td:nth-child(2) > h2 > a') ??
        // Theme 旅行者
        element.q('td:nth-child(1) > h2 > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.firstHref();
    final forumID = url?.split('fid=').lastOrNull?.parseToInt();

    final iconUrl = element.q('td > a > img')?.dataOriginalOrSrcImgUrl();

    final threadCount =
        (element.q('td:nth-child(3) > span:nth-child(1)') ??
                element.q('td:nth-child(2) > span:nth-child(1)'))
            ?.firstEndDeepText()
            ?.parseToInt();
    final replyCount =
        (element.q('td:nth-child(3) > span:nth-child(2)') ??
                element.q('td:nth-child(2) > span:nth-child(2)'))
            ?.firstEndDeepText()
            ?.split(' ')
            .lastOrNull
            ?.parseToInt();
    final threadTodayCount =
        (element.q('td:nth-child(2) > h2 > em') ??
                element.q('td:nth-child(1) > h2 > em'))
            ?.firstEndDeepText()
            ?.split('(')
            .lastOrNull
            ?.split(')')
            .firstOrNull
            ?.parseToInt() ??
        element
            .q('td:nth-child(2) > h2 > em:nth-child(3)')
            ?.firstEndDeepText()
            ?.parseToInt();

    final latestThreadNode =
        element.q('td:nth-child(4) > div') ??
        element.q('td:nth-child(3) > div');
    final latestThreadTime = latestThreadNode
        ?.q('cite > span')
        ?.attributes['title']
        ?.parseToDateTimeUtc8();
    final latestThreadTimeText = latestThreadNode
        ?.q('cite > span')
        ?.firstEndDeepText();
    final latestThreadUrl = latestThreadNode?.q('a')?.firstHref();

    final latestThreadTitle = latestThreadNode?.q('a')?.firstEndDeepText();
    final latestThreadUserName = latestThreadNode
        ?.q('cite > a')
        ?.firstEndDeepText();
    final latestThreadUserUrl = latestThreadNode?.q('cite > a')?.firstHref();

    final subForumList = element
        .qAll('td > p')
        .firstWhereOrNull(
          (e) => e.nodes.firstOrNull?.text?.contains('子版块') ?? false,
        )
        ?.qAll('a')
        .map(
          (e) =>
              (e.firstEndDeepText()?.trim() ?? '', e.attributes['href'] ?? ''),
        )
        .where((e) => e.$1.isNotEmpty && e.$2.isNotEmpty)
        .toList();

    final subThreadList = element
        .qAll('td > p a')
        .where((e) => e.attributes['href']?.contains('tid=') ?? false)
        .map((e) => (e.firstEndDeepText() ?? '', e.attributes['href'] ?? ''))
        .where((e) => e.$1.isNotEmpty && e.$2.isNotEmpty)
        .toList();

    return TsdmForum(
      forumID: forumID ?? -1,
      url: url ?? '',
      name: name ?? '',
      iconUrl: iconUrl ?? '',
      threadCount: threadCount ?? -1,
      replyCount: replyCount ?? -1,
      threadTodayCount: threadTodayCount,
      latestThreadTime: latestThreadTime,
      latestThreadTimeText: latestThreadTimeText,
      latestThreadUrl: latestThreadUrl,
      latestThreadTitle: latestThreadTitle,
      latestThreadUserName: latestThreadUserName,
      latestThreadUserUrl: latestThreadUserUrl,
      subForumList: subForumList,
      subThreadList: subThreadList,
    );
  }

  /// Build a collapsed forum from a `<td class="fl_g">` node.
  static TsdmForum buildCollapsedForum(dom.Element element) {
    final titleNode =
        element.q('div.tsdm_fl_inf > dl > dt > a') ??
        // Style 5
        element.q('dl > dt > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.firstHref();
    final forumID = url?.split('fid=').lastOrNull?.parseToInt();

    final iconUrl = element
        .q('div.fl_icn_g > a > img')
        ?.dataOriginalOrSrcImgUrl();

    final threadCount =
        element
            .q(
              'div.tsdm_fl_inf > dl > dd > em:nth-child(1) > span:nth-child(2)',
            )
            ?.firstEndDeepText()
            ?.parseToInt() ??
        element
            .q('div.tsdm_fl_inf > dl > dd > em:nth-child(1)')
            ?.firstEndDeepText()
            ?.split(' ')
            .elementAtOrNull(1)
            ?.parseToInt() ??
        element
            .q(
              'div.tsdm_fl_inf > dl > dd > em:nth-child(1) > font:nth-child(2)',
            )
            ?.firstEndDeepText()
            ?.parseToInt() ??
        element
            .q('dl > dd > em:nth-child(1)')
            ?.firstEndDeepText()
            ?.split(' ')
            .lastOrNull
            ?.parseToInt();
    final replyCount =
        element
            .q(
              'div.tsdm_fl_inf > dl > dd > em:nth-child(2) > span:nth-child(2)',
            )
            ?.firstEndDeepText()
            ?.parseToInt() ??
        element
            .q('div.tsdm_fl_inf > dl > dd > em:nth-child(2)')
            ?.firstEndDeepText()
            ?.split(' ')
            .elementAtOrNull(1)
            ?.parseToInt() ??
        element
            .q(
              'div.tsdm_fl_inf > dl > dd > em:nth-child(2) > font:nth-child(2)',
            )
            ?.firstEndDeepText()
            ?.parseToInt() ??
        element
            .q('dl > dd > em:nth-child(2)')
            ?.firstEndDeepText()
            ?.split(' ')
            .lastOrNull
            ?.parseToInt();
    final threadTodayCount =
        element
            .q('div.tsdm_fl_inf > dl > dd > em:nth-child(3)')
            ?.firstEndDeepText()
            ?.replaceFirst(' (', '')
            .replaceFirst(')', '')
            .parseToInt() ??
        element
            .q('div.tsdm_fl_inf > dl > dt > em')
            ?.firstEndDeepText()
            ?.replaceFirst(' (', '')
            .replaceFirst(')', '')
            .parseToInt() ??
        element
            .q(
              'div.tsdm_fl_inf > dl > dd > em:nth-child(3) > font:nth-child(2)',
            )
            ?.firstEndDeepText()
            ?.parseToInt() ??
        element
            .q('dl > dt > em')
            ?.firstEndDeepText()
            ?.split('(')
            .lastOrNull
            ?.split(')')
            .firstOrNull
            ?.parseToInt();

    final latestThreadNode = element.q(
      'div.tsdm_fl_inf > dl > dd:nth-child(3) > a',
    );
    var latestThreadTime = latestThreadNode
        ?.q('span')
        ?.attributes['title']
        ?.parseToDateTimeUtc8();
    final latestThreadTimeText = latestThreadNode?.text;
    if (latestThreadTime == null &&
        (latestThreadTimeText?.contains('最后发表: ') ?? false)) {
      latestThreadTime = latestThreadTimeText!
          .replaceFirst('最后发表: ', '')
          .parseToDateTimeUtc8();
    }
    final latestThreadUrl = latestThreadNode?.firstHref();

    return TsdmForum(
      forumID: forumID ?? -1,
      url: url ?? '',
      name: name ?? '',
      iconUrl: iconUrl ?? '',
      threadCount: threadCount ?? -1,
      replyCount: replyCount ?? -1,
      threadTodayCount: threadTodayCount,
      latestThreadTime: latestThreadTime,
      latestThreadTimeText: latestThreadTimeText,
      latestThreadUrl: latestThreadUrl,
    );
  }
}
