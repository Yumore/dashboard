import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_locked.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_post_checkin_status.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_post_medal.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_post_pokemon.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_rate.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user_brief_profile.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// A single floor (post) in a thread.
///
/// Ported from `tsdm_client/lib/shared/models/post.dart`
/// (`Post.fromPostNode` / `Post.buildListFromThreadDataNode`).
class TsdmPost {
  const TsdmPost({
    required this.postID,
    required this.postFloor,
    required this.author,
    required this.publishTime,
    required this.data,
    required this.replyAction,
    required this.rateAction,
    required this.lastEditUsername,
    required this.lastEditTime,
    required this.shareLink,
    required this.page,
    required this.isDraft,
    required this.packetAllTaken,
    this.locked = const [],
    this.rate,
    this.packetUrl,
    this.editUrl,
    this.userBriefProfile,
    this.hasPoll = false,
    this.postMedals,
    this.badge,
    this.secondBadge,
    this.signature,
    this.pokemon,
    this.checkin,
  });

  /// Post id.
  final String postID;

  /// Post floor number, nullable to support all web page styles.
  final int? postFloor;

  /// Post author.
  final TsdmUser author;

  /// Post publish time.
  final DateTime? publishTime;

  /// Post body html.
  final String data;

  /// Locked areas inside this post.
  final List<TsdmLocked> locked;

  /// Rate records of this post.
  final TsdmRate? rate;

  /// Url used to reply to this post.
  final String? replyAction;

  /// Url used to rate this post.
  final String? rateAction;

  /// Red packet url.
  final String? packetUrl;

  /// Whether all red packets were taken.
  final bool packetAllTaken;

  /// Url used to edit this post.
  final String? editUrl;

  /// Name of the user who edited this post last.
  final String? lastEditUsername;

  /// Time this post was edited last.
  final String? lastEditTime;

  /// Url used to share this floor.
  final String? shareLink;

  /// Brief profile of the author.
  final TsdmUserBriefProfile? userBriefProfile;

  /// Page this post was loaded from.
  final int page;

  /// Whether this post is an unpublished draft.
  final bool isDraft;

  /// Whether this post has a poll, unsupported and only flagged.
  final bool hasPoll;

  /// Medals of the author.
  final List<TsdmPostMedal>? postMedals;

  /// Image url of the main badge, usually the user group.
  final String? badge;

  /// Image url of the optional second badge.
  final String? secondBadge;

  /// Html signature.
  final String? signature;

  /// Pokemon of this floor.
  final TsdmPostPokemon? pokemon;

  /// Checkin status of the author.
  final TsdmPostCheckinStatus? checkin;

  /// Image url marking a fully taken red packet.
  static const emptyPacketImageUrl = 'static/image/post/rp-2.svg';

  /// Regex of the rate action url inside an `onclick` attribute.
  static final _rateActionRe = RegExp("'rate', '(?<url>forum.php[^']*)',");

  /// Build a post from an element whose id is `post_$postID`.
  ///
  /// Returns null when the post id or the author is invalid, as the source.
  static TsdmPost? fromPostNode(dom.Element element, int page) {
    final trRootNode = element.q('table > tbody > tr');
    final postID = element.id.replaceFirst('post_', '');
    if (postID.isEmpty) {
      return null;
    }
    final avatarId = 'ts_avatar_$postID';

    final postInfoNode = trRootNode?.q('td:nth-child(1) > div#$avatarId');
    final postAuthorName = postInfoNode?.q('div')?.firstEndDeepText();
    final postAuthorUrl = postInfoNode?.q('div.avatar > a')?.attributes['href'];
    final postAuthorUid = postAuthorUrl?.split('uid=').elementAtOrNull(1);
    final postAuthorAvatarNode = postInfoNode?.q('div.avatar > a > img');
    final postAuthorAvatarUrl =
        postAuthorAvatarNode?.attributes['data-original'] ??
        postAuthorAvatarNode?.attributes['src'];

    final postAuthor = TsdmUser(
      name: postAuthorName ?? '',
      uid: postAuthorUid,
      url: postAuthorUrl?.prependHost() ?? '',
      avatarUrl: postAuthorAvatarUrl,
    );
    if (postAuthor.isNotValid()) {
      return null;
    }

    // package:html's csslib does not reliably resolve `:nth-child(2)`,
    // so take the second cell explicitly.
    final postDataNode = trRootNode?.qAll('td').elementAtOrNull(1);
    final postPublishTimeNode = postDataNode?.q('#authorposton$postID');
    final postPublishTime = postPublishTimeNode?.dateTime();

    // The `#postmessage_ID` id sometimes does not match the post id, so the
    // content is matched through `div.pcb`, falling back to the poll layout
    // `div.pcbs`.
    final postData =
        postDataNode?.q('div.pcb')?.innerHtml ??
        postDataNode?.q('div.pcbs')?.innerHtml;

    // Already purchased locked blocks carry a `<span>` and are skipped here.
    final locked = postDataNode
        ?.qAll('div.locked')
        .where((e) => e.q('span') == null)
        .map(
          (e) => TsdmLocked.fromLockDivNode(
            e,
            allowWithPoints: false,
            allowWithReply: false,
            allowWithAuthor: false,
            allowWithBlocked: false,
          ),
        )
        .whereType<TsdmLocked>()
        .toList();

    final hasPoll = postDataNode?.q('form#poll') != null;

    final postFloor = postDataNode
        ?.q('div.pi > strong > a > em')
        ?.firstEndDeepText()
        ?.parseToInt();
    final shareLink = postDataNode
        ?.q('div.pi > strong > a')
        ?.attributes['href']
        ?.prependHost();

    final replyAction = element
        .q(
          'table > tbody > tr:nth-child(2) > td.tsdm_replybar div.pob em > a[href*="action=reply"]',
        )
        ?.firstHref();

    final rate = TsdmRate.fromRateLogNode(
      postDataNode?.q('div.pct > div.pcb > dl.rate'),
    );
    final packetUrl = postDataNode
        ?.q('div.pct > div#ts_packet > a')
        ?.attributes['href']
        ?.prependHost();
    final packetAllTaken =
        postDataNode
            ?.q('div.pct > div#ts_packet > a > img')
            ?.attributes['src'] ==
        emptyPacketImageUrl;

    var rateAction = _rateActionOf(
      element.q('table  div.pob.cl p > a[onclick*="action=rate"]'),
    );
    rateAction ??= _rateActionOf(
      element.q('div#fj > a[onclick*="action=rate"]'),
    );

    final editUrl = element
        .qAll('div#fj > a')
        .firstWhereOrNull((e) => e.firstEndDeepText() == '编辑')
        ?.attributes['href']
        ?.prependHost();

    // 本帖最后由 $username 于 xxxx-xx-xx xx:xx:xx 编辑
    final lastEditText = element.q('i.pstatus')?.text.trim().split(' ');
    String? lastEditUsername;
    String? lastEditTime;
    if (lastEditText != null && lastEditText.length >= 5) {
      lastEditText.removeLast(); // 编辑
      final time = lastEditText.removeLast();
      final date = lastEditText.removeLast();
      lastEditText
        ..removeLast() // 于
        ..removeAt(0); // 本帖最后由
      lastEditUsername = lastEditText.join(' ');
      lastEditTime = '$date $time';
    }

    final userProfileNode = element.q(
      'table > tbody > tr:nth-child(1) > td.pls',
    );
    final userBriefProfile = userProfileNode == null
        ? null
        : TsdmUserBriefProfile.buildFromUserProfileNode(userProfileNode);

    final isDraft = element.q('a.psave') != null;

    final postMedals = element
        .qAll('div.md_ctrl > a > img')
        .map(TsdmPostMedal.fromImg)
        .whereType<TsdmPostMedal>()
        .toList();

    final badge = element
        .q('div#$avatarId > div.tsdm_norm_title > img')
        ?.imageUrl();
    final secondBadge =
        element.q('div.tsdm_statbar > a > img.tsdmtitles')?.imageUrl() ??
        element.q('div.tsdm_statbar > a > img.tsdm_lv_title')?.imageUrl();
    final signature = element.q('div.sign_inner')?.innerHtml;

    final pokemonNode = element.q('div.tsdm_pokemon');
    final pokemon = pokemonNode == null
        ? null
        : TsdmPostPokemon.fromDiv(pokemonNode);

    final checkinNode = element.q('div.qdsmile');
    final checkin = checkinNode == null
        ? null
        : TsdmPostCheckinStatus.fromDiv(checkinNode);

    return TsdmPost(
      postID: postID,
      postFloor: postFloor,
      author: postAuthor,
      publishTime: postPublishTime,
      data: postData ?? '',
      locked: locked ?? [],
      replyAction: replyAction,
      rate: rate,
      rateAction: rateAction,
      packetUrl: packetUrl,
      packetAllTaken: packetAllTaken,
      editUrl: editUrl,
      lastEditUsername: lastEditUsername,
      lastEditTime: lastEditTime,
      userBriefProfile: userBriefProfile,
      shareLink: shareLink,
      page: page,
      isDraft: isDraft,
      hasPoll: hasPoll,
      postMedals: postMedals,
      badge: badge,
      secondBadge: secondBadge,
      signature: signature,
      pokemon: pokemon,
      checkin: checkin,
    );
  }

  /// Extract the rate action url of an anchor node, host prefixed.
  static String? _rateActionOf(dom.Element? anchor) {
    final onclick = anchor?.attributes['onclick'];
    if (onclick == null) {
      return null;
    }
    return _rateActionRe.firstMatch(onclick)?.namedGroup('url')?.prependHost();
  }

  /// Build the post list from the `div#postlist` node.
  ///
  /// The posts are the `nextElementSibling` chain starting at `div.bm > div` or
  /// at the third child, of which every node whose id starts with `post_` is
  /// parsed. Returns an empty list when [element] is null.
  static List<TsdmPost> buildListFromThreadDataNode(
    dom.Element? element,
    int page,
  ) {
    if (element == null) {
      return [];
    }
    final threadDataRootNode =
        element.q('div.bm > div') ?? element.childAtOrNull(2);
    var currentElement = threadDataRootNode;
    final postList = <TsdmPost>[];
    while (currentElement != null) {
      if ((currentElement.attributes['id'] ?? '').startsWith('post_')) {
        final post = TsdmPost.fromPostNode(currentElement, page);
        if (post == null) {
          currentElement = currentElement.nextElementSibling;
          continue;
        }
        postList.add(post);
      }
      currentElement = currentElement.nextElementSibling;
    }
    return postList;
  }
}
