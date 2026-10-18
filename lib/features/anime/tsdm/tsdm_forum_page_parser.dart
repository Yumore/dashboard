import 'package:dashboard/features/anime/tsdm/tsdm_forum.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_normal_thread.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_stick_thread.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_filter.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Parsed content of a forum display page.
///
/// Ported from the `_parseFromDocument` method of
/// `tsdm_client/lib/features/forum/bloc/forum_bloc.dart`.
class TsdmForumPageData {
  /// Create parsed forum page data.
  const TsdmForumPageData({
    required this.title,
    required this.rulesElement,
    required this.stickThreadList,
    required this.normalThreadList,
    required this.subredditList,
    required this.canLoadMore,
    required this.currentPage,
    required this.totalPages,
    required this.havePermission,
    required this.permissionDeniedMessage,
    required this.needLogin,
    required this.filterTypeList,
    required this.filterSpecialTypeList,
    required this.filterOrderList,
    required this.filterDatelineList,
  });

  /// Forum title, null when the page has none.
  final String? title;

  /// Forum rules node, null when the forum has no rules.
  final dom.Element? rulesElement;

  /// Pinned threads of the page.
  final List<TsdmStickThread> stickThreadList;

  /// Normal threads of the page.
  final List<TsdmNormalThread> normalThreadList;

  /// Sub forums of the page.
  final List<TsdmForum> subredditList;

  /// Whether another page can be loaded.
  final bool canLoadMore;

  /// Current page number.
  final int currentPage;

  /// Total page count.
  final int totalPages;

  /// Whether the current user may read this forum.
  final bool havePermission;

  /// Message shown when the user may not read this forum.
  final dom.Element? permissionDeniedMessage;

  /// Whether the user has to log in first.
  final bool needLogin;

  /// Available thread type filters.
  final List<TsdmFilterType> filterTypeList;

  /// Available special thread filters.
  final List<TsdmFilterSpecialType> filterSpecialTypeList;

  /// Available order filters.
  final List<TsdmFilterOrder> filterOrderList;

  /// Available dateline filters.
  final List<TsdmFilterDateline> filterDatelineList;
}

/// Parser of the forum display page.
class TsdmForumPageParser {
  const TsdmForumPageParser._();

  static final _typeIDRe = RegExp(r'&typeid=(?<id>\d+)');
  static final _specialTypeRe = RegExp('&specialtype=(?<type>[a-z]+)');
  static final _orderByRe = RegExp('&orderby=(?<orderby>[a-z]+)');
  static final _datelineRe = RegExp(r'&dateline=(?<dateline>\d+)');

  /// Parse [document] of forum [fid], page [pageNumber].
  static TsdmForumPageData parse(
    dom.Document document,
    String fid,
    int pageNumber,
  ) {
    final title = document.q('div#ct h1.xs2 > a')?.text;

    final normalThreadList = <TsdmNormalThread>[];
    for (final element in document.qAll('tbody.tsdm_normalthread')) {
      final thread = TsdmNormalThread.fromTBody(element);
      if (thread != null) {
        normalThreadList.add(thread);
      }
    }

    final stickThreadList = <TsdmStickThread>[];
    for (final element in document.qAll('tbody.tsdm_stickthread')) {
      final thread = TsdmStickThread.fromTBody(element);
      if (thread != null) {
        stickThreadList.add(thread);
      }
    }

    final subredditList = <TsdmForum>[];
    final subforumNode = document.q('div#subforum_$fid');
    if (subforumNode != null) {
      for (final element in subforumNode.qAll('table > tbody > tr')) {
        final forum = TsdmForum.fromFlRowNode(element);
        if (forum != null) {
          subredditList.add(forum);
        }
      }
    }

    var havePermission = true;
    var needLogin = false;
    dom.Element? permissionDeniedMessage;
    if (normalThreadList.isEmpty && subredditList.isEmpty) {
      final documentMessage =
          document.getElementById('messagetext') ??
          document.getElementById('messagelogin');
      if (documentMessage != null) {
        havePermission = false;
        needLogin = documentMessage.id == 'messagelogin';
        permissionDeniedMessage = documentMessage.q('p');
      }
    }

    return TsdmForumPageData(
      title: title,
      rulesElement: document.q('div#forum_rules_$fid'),
      stickThreadList: stickThreadList,
      normalThreadList: normalThreadList,
      subredditList: subredditList,
      // The source logs an error and returns false when `div#pgt` is missing,
      // which the port reports through [TsdmForumPageData.canLoadMore].
      canLoadMore: document.checkCanLoadMore(),
      currentPage: document.currentPage() ?? pageNumber,
      totalPages: document.totalPages() ?? 1,
      havePermission: havePermission,
      permissionDeniedMessage: permissionDeniedMessage,
      needLogin: needLogin,
      filterTypeList: _parseFilterList<TsdmFilterType>(
        document.q('ul#thread_types'),
        (name, value) => TsdmFilterType(
          name: name,
          typeID: _typeIDRe.firstMatch(value)?.namedGroup('id'),
        ),
      ),
      filterSpecialTypeList: _parseFilterList<TsdmFilterSpecialType>(
        document.q('div#filter_special_menu'),
        (name, value) => TsdmFilterSpecialType(
          name: name,
          specialType: _specialTypeRe.firstMatch(value)?.namedGroup('type'),
        ),
      ),
      filterOrderList: _parseFilterList<TsdmFilterOrder>(
        document.q('div#filter_orderby_menu'),
        (name, value) => TsdmFilterOrder(
          name: name,
          orderBy: _orderByRe.firstMatch(value)?.namedGroup('orderby'),
        ),
      ),
      filterDatelineList: _parseFilterList<TsdmFilterDateline>(
        document.q('div#filter_dateline_menu'),
        (name, value) => TsdmFilterDateline(
          name: name,
          dateline: _datelineRe.firstMatch(value)?.namedGroup('dateline'),
        ),
      ),
    );
  }

  static List<T> _parseFilterList<T>(
    dom.Element? root,
    T Function(String name, String href) build,
  ) {
    if (root == null) {
      return const [];
    }
    final result = <T>[];
    for (final element in root.qAll('li > a')) {
      final name = element.text.trim();
      final href = element.attributes['href'] ?? '';
      result.add(build(name, href));
    }
    return result;
  }
}
