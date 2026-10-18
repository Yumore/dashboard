import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// The reason a post area is hidden.
enum TsdmLockedKind {
  /// Requires the viewer to have at least a number of points.
  points,

  /// Requires the viewer to purchase.
  purchase,

  /// Requires the viewer to reply.
  reply,

  /// Only visible to the author and forum moderators.
  author,

  /// Blocked by a moderator.
  blocked,

  /// The viewer is selling this content.
  sale,
}

/// A locked area inside a thread or a post.
///
/// Ported from `tsdm_client/lib/shared/models/locked.dart`
/// (`Locked.fromLockDivNode`).
class TsdmLocked {
  const TsdmLocked._({
    required this.kind,
    this.requiredPoints,
    this.points,
    this.price,
    this.purchasedCount,
    this.tid,
    this.pid,
  });

  /// Which kind of lock this is.
  final TsdmLockedKind kind;

  /// Required points to view, only for [TsdmLockedKind.points].
  final int? requiredPoints;

  /// Points the current user has, only for [TsdmLockedKind.points].
  final int? points;

  /// Price, only for purchase and sale locks.
  final int? price;

  /// Purchased count, only for purchase and sale locks.
  final int? purchasedCount;

  /// Thread id, only for purchase and sale locks.
  final String? tid;

  /// Post id, only for purchase locks.
  final String? pid;

  /// Regex of the purchase link, kept identical to the source.
  static final _purchaseRe = RegExp(
    r'forum.php\?mod=misc&action=pay&tid=(?<tid>\d+)&pid=(?<pid>\d+)',
  );

  /// Regex of the required-points notice, kept identical to the source.
  static final _pointsRe = RegExp(
    r'高于 (?<requiredPoints>\d+) 才可浏览(，您当前积分为 (?<points>\d+))?',
  );

  /// Whether this lock requires points.
  bool get lockedWithPoints => kind == TsdmLockedKind.points;

  /// Whether this lock requires a purchase.
  bool get lockedWithPurchase => kind == TsdmLockedKind.purchase;

  /// Whether this lock requires a reply.
  bool get lockedWithReply => kind == TsdmLockedKind.reply;

  /// Whether this lock is only visible to the author.
  bool get lockedWithAuthor => kind == TsdmLockedKind.author;

  /// Whether this lock was set by a moderator.
  bool get lockedWithBlocked => kind == TsdmLockedKind.blocked;

  /// Whether this lock is a sale performed by the current user.
  bool get lockedWithSale => kind == TsdmLockedKind.sale;

  /// Whether this lock is valid and can be shown.
  bool get isValid {
    switch (kind) {
      case TsdmLockedKind.reply:
      case TsdmLockedKind.points:
      case TsdmLockedKind.author:
      case TsdmLockedKind.blocked:
        return true;
      case TsdmLockedKind.purchase:
        return (price ?? 0) > 0 && tid != null && pid != null;
      case TsdmLockedKind.sale:
        return (price ?? 0) > 0 && tid != null;
    }
  }

  /// Whether this lock is invalid.
  bool get isNotValid => !isValid;

  /// Build a lock from a `<div class="locked">` node.
  ///
  /// The check order matters and is exactly the source order: author, reply,
  /// purchase, sale, blocked, points.
  static TsdmLocked? fromLockDivNode(
    dom.Element element, {
    bool allowWithPoints = true,
    bool allowWithPurchase = true,
    bool allowWithReply = true,
    bool allowWithAuthor = true,
    bool allowWithBlocked = true,
    bool allowWithSales = true,
  }) {
    if (allowWithAuthor &&
        element.nodes.length == 1 &&
        (element.nodes[0].text?.contains('仅作者可见') ?? false)) {
      return const TsdmLocked._(kind: TsdmLockedKind.author);
    }

    if (allowWithReply && element.innerHtml.contains('查看本帖隐藏内容请回复')) {
      return const TsdmLocked._(kind: TsdmLockedKind.reply);
    }

    final price = element
        .q('strong')
        ?.firstEndDeepText()
        ?.split(' ')
        .firstOrNull
        ?.parseToInt();
    final purchasedCount = element
        .q('em')
        ?.firstEndDeepText()
        ?.split(' ')
        .elementAtOrNull(1)
        ?.parseToInt();

    final purchaseMatch = _purchaseRe.firstMatch(
      element.q('a')?.attributes['onclick'] ?? '',
    );
    final purchaseTid = purchaseMatch?.namedGroup('tid');
    final purchasePid = purchaseMatch?.namedGroup('pid');
    if (price != null && purchaseTid != null && purchasePid != null) {
      if (!allowWithPurchase) {
        return null;
      }
      return TsdmLocked._(
        kind: TsdmLockedKind.purchase,
        price: price,
        purchasedCount: purchasedCount,
        tid: purchaseTid,
        pid: purchasePid,
      );
    }

    final salesTid = element
        .q('em > a')
        ?.attributes['href']
        ?.uriQueryParameter('tid');
    final salesCount = element
        .q('span.pipe')
        ?.nextElementSibling
        ?.firstEndDeepText()
        ?.split(' ')
        .lastOrNull
        ?.parseToInt();
    if (price != null && salesTid != null && salesCount != null) {
      if (!allowWithSales) {
        return null;
      }
      return TsdmLocked._(
        kind: TsdmLockedKind.sale,
        price: price,
        purchasedCount: salesCount,
        tid: salesTid,
      );
    }

    if (allowWithBlocked && element.innerHtml.contains('该帖被管理员或版主屏蔽')) {
      return const TsdmLocked._(kind: TsdmLockedKind.blocked);
    }

    if (!allowWithPoints) {
      return null;
    }

    final match = _pointsRe.firstMatch(element.innerHtml);
    final requiredPoints = match?.namedGroup('requiredPoints')?.parseToInt();
    final points = match?.namedGroup('points')?.parseToInt();
    if (requiredPoints == null) {
      return null;
    }
    return TsdmLocked._(
      kind: TsdmLockedKind.points,
      requiredPoints: requiredPoints,
      points: points,
    );
  }
}
