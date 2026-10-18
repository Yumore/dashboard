import 'package:dashboard/features/anime/tsdm/tsdm_normal_thread.dart';
import 'package:html/dom.dart' as dom;

/// A pinned thread entry in a forum list.
///
/// Ported from `tsdm_client/lib/shared/models/stick_thread.dart`: the source
/// copies every parsed field of a [TsdmNormalThread] into a distinct type so
/// pinned threads stay distinguishable.
class TsdmStickThread extends TsdmNormalThread {
  /// Create a pinned thread entry from the fields of a normal thread.
  const TsdmStickThread({
    required super.title,
    required super.url,
    required super.threadID,
    required super.author,
    required super.publishDate,
    required super.latestReplyAuthor,
    required super.latestReplyTime,
    required super.iconUrl,
    required super.threadType,
    required super.replyCount,
    required super.viewCount,
    required super.price,
    required super.privilege,
    required super.css,
    required super.stateSet,
    required super.isRecentThread,
  });

  /// Build from a `<tbody class="tsdm_stickthread">` node.
  static TsdmStickThread? fromTBody(dom.Element threadElement) {
    final thread = TsdmNormalThread.fromTBody(threadElement);
    if (thread == null) {
      return null;
    }
    return TsdmStickThread(
      title: thread.title,
      url: thread.url,
      threadID: thread.threadID,
      author: thread.author,
      publishDate: thread.publishDate,
      latestReplyAuthor: thread.latestReplyAuthor,
      latestReplyTime: thread.latestReplyTime,
      iconUrl: thread.iconUrl,
      threadType: thread.threadType,
      replyCount: thread.replyCount,
      viewCount: thread.viewCount,
      price: thread.price,
      privilege: thread.privilege,
      css: thread.css,
      stateSet: thread.stateSet,
      isRecentThread: thread.isRecentThread,
    );
  }
}
