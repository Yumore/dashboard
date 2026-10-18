import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Forum of the tsdm board.
///
/// Ported from `tsdm_client/lib/shared/models/forum.dart`.
class TsdmForum {
  const TsdmForum({
    required this.forumID,
    required this.url,
    required this.name,
    required this.iconUrl,
    required this.threadCount,
    required this.replyCount,
    required this.threadTodayCount,
    required this.latestThreadTime,
    required this.latestThreadTimeText,
    required this.latestThreadUrl,
    this.latestThreadTitle,
    this.latestThreadUserName,
    this.latestThreadUserUrl,
    this.subForumList,
    this.subThreadList,
  });

  /// Forum id as in url query parameter `fid`.
  final int forumID;

  /// Url of this forum.
  final String url;

  /// Forum name.
  final String name;

  /// Icon image url.
  final String iconUrl;

  /// Thread count.
  final int threadCount;

  /// Reply count.
  final int replyCount;

  /// Thread count published today.
  final int? threadTodayCount;

  /// Parsed time of the latest thread.
  final DateTime? latestThreadTime;

  /// Raw text of the latest thread time, fallback display.
  final String? latestThreadTimeText;

  /// Url of the latest thread.
  final String? latestThreadUrl;

  /// Title of the latest thread, expanded layout only.
  final String? latestThreadTitle;

  /// Name of the latest thread publisher, expanded layout only.
  final String? latestThreadUserName;

  /// Url of the latest thread publisher, expanded layout only.
  final String? latestThreadUserUrl;

  /// Sub forums, expanded layout only.
  final List<(String, String)>? subForumList;

  /// Sub threads, expanded layout only.
  final List<(String, String)>? subThreadList;

  /// Whether this forum entry points at a real forum.
  bool get isExpanded =>
      latestThreadTitle != null && latestThreadUserName != null;

  /// Build a [TsdmForum] from an expanded `<tr class="fl_row">` node.
  ///
  /// Ported from `Forum.fromFlRowNode` of
  /// `tsdm_client/lib/shared/models/forum.dart`; the newer selectors
  /// (`td:nth-child(2)`, `td:nth-child(3)`, `td:nth-child(4)`) are tried first
  /// and fall back to the older ones (`td:nth-child(1)`, `td:nth-child(2)`,
  /// `td:nth-child(3)`). Null is returned when the name, the forum id or the
  /// thread/reply counters cannot be read.
  static TsdmForum? fromFlRowNode(dom.Element element) {
    final titleNode =
        element.q('td:nth-child(2) > h2 > a') ??
        element.q('td:nth-child(1) > h2 > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.attributes['href'];
    final forumID = url?.split('fid=').lastOrNull?.parseToInt();
    if (name == null || forumID == null || url == null) {
      return null;
    }
    final iconUrl = element.q('td > a > img')?.dataOriginalOrSrcImgUrl() ?? '';
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
    if (threadCount == null || replyCount == null) {
      return null;
    }
    final todayNode =
        element.q('td:nth-child(2) > h2 > em') ??
        element.q('td:nth-child(1) > h2 > em');
    final threadTodayCount =
        (todayNode
            ?.firstEndDeepText()
            ?.split('(')
            .lastOrNull
            ?.split(')')
            .firstOrNull
            ?.parseToInt()) ??
        element
            .q('td:nth-child(2) > h2 > em:nth-child(3)')
            ?.firstEndDeepText()
            ?.parseToInt();

    final latestThreadNode =
        element.q('td:nth-child(4) > div') ??
        element.q('td:nth-child(3) > div');
    final latestThreadTimeNode = latestThreadNode?.q('cite > span');
    final latestThreadTime = latestThreadTimeNode?.attributes['title']
        ?.parseToDateTimeUtc8();
    final latestThreadTimeText = latestThreadTimeNode?.firstEndDeepText();
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
        .map((e) => (e.firstEndDeepText()?.trim(), e.attributes['href']))
        .whereType<(String, String)>()
        .toList();
    final subThreadList = element
        .qAll('td > p a')
        .where((e) => e.attributes['href']?.contains('tid=') ?? false)
        .map((e) => (e.firstEndDeepText()?.trim(), e.attributes['href']))
        .whereType<(String, String)>()
        .toList();

    return TsdmForum(
      forumID: forumID,
      url: url,
      name: name,
      iconUrl: iconUrl,
      threadCount: threadCount,
      replyCount: replyCount,
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
}
