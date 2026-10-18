import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_post.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_breadcrumb.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_type.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Reply parameters read from the fast reply form of a thread page.
///
/// Ported from `ReplyParameters` used by
/// `tsdm_client/lib/features/thread/v1/bloc/thread_bloc.dart`.
class TsdmReplyParameters {
  /// Create reply parameters.
  const TsdmReplyParameters({
    required this.fid,
    required this.formHash,
    required this.subject,
    this.postTime,
  });

  /// Forum id.
  final int fid;

  /// Form hash required by the reply form.
  final String formHash;

  /// Reply subject.
  final String subject;

  /// Post time of the thread, null when the page did not provide one.
  final String? postTime;
}

/// Parsed content of a thread page.
class TsdmThreadPageData {
  /// Create parsed thread page data.
  const TsdmThreadPageData({
    required this.tid,
    required this.title,
    required this.forumName,
    required this.threadSoftClosed,
    required this.threadClosed,
    required this.postList,
    required this.needLogin,
    required this.havePermission,
    required this.permissionDeniedMessage,
    required this.threadType,
    required this.replyParameters,
    required this.isDraft,
    required this.latestModAct,
    required this.breadcrumbs,
    required this.viewCount,
    required this.replyCount,
    required this.canLoadMore,
    required this.currentPage,
    required this.totalPages,
  });

  /// Thread id parsed from the canonical link of the page.
  final String? tid;

  /// Thread title.
  final String? title;

  /// Forum name, the second to last breadcrumb.
  final String? forumName;

  /// Whether the thread shows the soft-closed marker.
  final bool threadSoftClosed;

  /// Whether the thread has no fast reply form, which means it is closed.
  final bool threadClosed;

  /// Posts of the page.
  final List<TsdmPost> postList;

  /// Whether the user has to log in first.
  final bool needLogin;

  /// Whether the user may read this thread.
  final bool havePermission;

  /// Message shown when the user may not read this thread.
  final dom.Element? permissionDeniedMessage;

  /// Thread type of the current thread.
  final TsdmThreadType? threadType;

  /// Reply parameters of the fast reply form.
  final TsdmReplyParameters? replyParameters;

  /// Whether the thread is a draft.
  final bool isDraft;

  /// Latest moderation action text.
  final String? latestModAct;

  /// Breadcrumbs between the forum group and the thread.
  final List<TsdmThreadBreadcrumb> breadcrumbs;

  /// Thread view count.
  final int? viewCount;

  /// Thread reply count.
  final int? replyCount;

  /// Whether another page can be loaded.
  final bool canLoadMore;

  /// Current page number.
  final int currentPage;

  /// Total page count.
  final int totalPages;
}

/// Parser of a thread page.
///
/// Ported from `_parseFromDocument` of
/// `tsdm_client/lib/features/thread/v1/bloc/thread_bloc.dart`.
class TsdmThreadPageParser {
  const TsdmThreadPageParser._();

  /// Parse [document] of thread page [pageNumber].
  static TsdmThreadPageData parse(dom.Document document, int pageNumber) {
    final tid = document
        .q('head > link')
        ?.attributes['href']
        ?.tryParseAsUri()
        ?.queryParameters['tid'];

    final threadSoftClosed =
        document.q('div#postlist h1.ts img[title="关闭"]') != null;
    final threadClosed = document.q('form#fastpostform') == null;

    final postList = TsdmPost.buildListFromThreadDataNode(
      document.q('div#postlist'),
      document.currentPage() ?? 1,
    );

    final title = document.q('a#thread_subject')?.text.trim();

    final breadcrumbNodes = document.qAll('div#pt a');
    final String? forumName;
    if (breadcrumbNodes.length < 2) {
      forumName = null;
    } else {
      forumName = breadcrumbNodes
          .elementAt(breadcrumbNodes.length - 2)
          .text
          .trim();
    }

    var havePermission = true;
    var needLogin = false;
    dom.Element? permissionDeniedMessage;
    if (postList.isEmpty) {
      final documentMessage =
          document.getElementById('messagetext') ??
          document.getElementById('messagelogin');
      if (documentMessage != null) {
        havePermission = false;
        needLogin = documentMessage.id == 'messagelogin';
        permissionDeniedMessage = documentMessage.q('p');
      }
    }

    final threadTypeNode = document.q('div#postlist h1.ts > a');
    TsdmThreadType? threadType;
    if (threadTypeNode != null) {
      final name = threadTypeNode
          .firstEndDeepText()
          ?.replaceFirst('[', '')
          .replaceFirst(']', '');
      final url = threadTypeNode.firstHref();
      threadType = TsdmThreadType.parse(name, url);
    }

    final fid = document
        .q('input[name="srhfid"]')
        ?.attributes['value']
        ?.parseToInt();
    final formHash = document.q('input[name="formhash"]')?.attributes['value'];
    final subject = document.q('input[name="subject"]')?.attributes['value'];
    final postTime = document.q('input[name="posttime"]')?.attributes['value'];
    TsdmReplyParameters? replyParameters;
    if (fid != null && formHash != null && subject != null) {
      replyParameters = TsdmReplyParameters(
        fid: fid,
        formHash: formHash,
        subject: subject,
        postTime: postTime,
      );
    }

    final draftNode = document.q('div#postlist h1.ts > span');
    final isDraft = draftNode?.nodes.firstOrNull?.text?.contains('草稿') ?? false;

    final latestModAct = document.q('div.modact')?.text;

    final breadcrumbs = <TsdmThreadBreadcrumb>[];
    final rawBreadcrumbs = document
        .qAll('div#pt > div.z > a')
        .map(
          (e) =>
              (e.text, Uri.tryParse(e.attributes['href']?.prependHost() ?? '')),
        )
        .whereType<(String, Uri)>()
        .skipWhile((e) => !(e.$2.queryParameters.containsKey('gid')))
        .map((e) => TsdmThreadBreadcrumb(description: e.$1, link: e.$2))
        .toList();
    if (rawBreadcrumbs.length > 1) {
      rawBreadcrumbs.removeLast();
    }
    breadcrumbs.addAll(rawBreadcrumbs);

    final statistics = document
        .qAll('div#postlist > table:nth-child(1) span.xi1')
        .map((e) => e.firstEndDeepText()?.parseToInt())
        .whereType<int>()
        .toList();
    final int? viewCount;
    final int? replyCount;
    if (statistics.length == 2) {
      viewCount = statistics.first;
      replyCount = statistics.elementAt(1);
    } else {
      viewCount = null;
      replyCount = null;
    }

    final currentPage = document.currentPage() ?? pageNumber;
    final totalPages = document.totalPages() ?? 1;

    return TsdmThreadPageData(
      tid: tid,
      title: title,
      forumName: forumName,
      threadSoftClosed: threadSoftClosed,
      threadClosed: threadClosed,
      postList: postList,
      needLogin: needLogin,
      havePermission: havePermission,
      permissionDeniedMessage: permissionDeniedMessage,
      threadType: threadType,
      replyParameters: replyParameters,
      isDraft: isDraft,
      latestModAct: latestModAct,
      breadcrumbs: breadcrumbs,
      viewCount: viewCount,
      replyCount: replyCount,
      canLoadMore: currentPage < totalPages,
      currentPage: currentPage,
      totalPages: totalPages,
    );
  }
}
