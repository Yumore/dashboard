import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// A thread entry of a search result page.
///
/// Ported from `tsdm_client/lib/features/search/models/searched_thread.dart`.
class TsdmSearchedThread {
  const TsdmSearchedThread({
    required this.tid,
    required this.title,
    required this.url,
    required this.author,
    required this.publishTime,
    required this.forumName,
    required this.forumUrl,
  });

  /// Thread id.
  final int tid;

  /// Thread title.
  final String title;

  /// Thread url.
  final String url;

  /// Thread author.
  final TsdmUser author;

  /// Publish time.
  final DateTime publishTime;

  /// Forum name.
  final String forumName;

  /// Forum url.
  final String forumUrl;

  /// Alias of [tid], matching the source model.
  int get threadID => tid;

  /// Regex extracting the tid from a thread url.
  static final _tidRe = RegExp(r'tid=(?<tid>\d+)');

  /// Build from a `<div class="ts_se_rs">` node.
  ///
  /// Returns null when any field is missing. The publish time text carries a
  /// two character prefix which is stripped before parsing, as the source does.
  static TsdmSearchedThread? fromDivNode(dom.Element element) {
    final titleNode = element.q('p:nth-child(1) > a');
    final title = titleNode?.firstEndDeepText()?.trim();
    final url = titleNode?.firstHref();

    final userNode = element.q('p:nth-child(2) > a');
    final username = userNode?.firstEndDeepText()?.trim();
    final userUrl = userNode?.firstHref();

    final publishTimeText = element
        .q('p:nth-child(2) > span.dateshow')
        ?.firstEndDeepText()
        ?.trim();
    final publishTime = publishTimeText == null || publishTimeText.length < 2
        ? null
        : publishTimeText.substring(2).parseToDateTimeUtc8();

    final forumNode = element.q('p:nth-child(2) > span.fid > a.forum_l');
    final forumName = forumNode?.firstEndDeepText()?.trim();
    final forumUrl = forumNode?.firstHref();

    if (title == null ||
        url == null ||
        username == null ||
        userUrl == null ||
        publishTime == null ||
        forumName == null ||
        forumUrl == null) {
      return null;
    }

    final tid = _tidRe.firstMatch(url)?.namedGroup('tid')?.parseToInt();
    if (tid == null) {
      return null;
    }

    return TsdmSearchedThread(
      tid: tid,
      title: title,
      url: url,
      author: TsdmUser(name: username, url: userUrl),
      publishTime: publishTime,
      forumName: forumName,
      forumUrl: forumUrl,
    );
  }
}
