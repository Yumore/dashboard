import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_css_color.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// A brief user profile shown next to a post in a thread page.
///
/// Ported from `tsdm_client/lib/shared/models/user_brief_profile.dart`
/// (`UserBriefProfile.buildFromUserProfileNode`).
class TsdmUserBriefProfile {
  const TsdmUserBriefProfile({
    required this.username,
    required this.avatarUrl,
    required this.uid,
    required this.nickname,
    required this.userGroup,
    required this.userGroupColor,
    required this.title,
    required this.recommended,
    required this.threadCount,
    required this.postCount,
    required this.famous,
    required this.coins,
    required this.publicity,
    required this.natural,
    required this.scheming,
    required this.spirit,
    required this.specialAttr,
    required this.specialAttrName,
    required this.couple,
    required this.privilege,
    required this.registrationDate,
    required this.comeFrom,
    required this.online,
  });

  /// Username, 用户名.
  final String username;

  /// User avatar url.
  final String? avatarUrl;

  /// User id, UID.
  final String uid;

  /// Custom nickname, 昵称.
  final String? nickname;

  /// Name of the user group, 用户组.
  final String userGroup;

  /// Additional color of the user group, when present.
  final Color? userGroupColor;

  /// Custom user title, 自定义头衔.
  final String? title;

  /// Recommended thread count, 精华.
  final String recommended;

  /// Thread count, 主题.
  final String threadCount;

  /// Post count, 帖子.
  final String postCount;

  /// 威望.
  final String famous;

  /// 天使币.
  final String coins;

  /// 宣传度.
  final String publicity;

  /// 天然°.
  final String natural;

  /// 腹黑°.
  final String scheming;

  /// 精灵.
  final String spirit;

  /// Special attr that changes over time, e.g. 龙之印章 / 西瓜 / 爱心 / 金蛋 / 魔法石.
  final String specialAttr;

  /// Name of [specialAttr].
  final String specialAttrName;

  /// Couple username, CP.
  final String? couple;

  /// Read privilege, 阅读权限.
  final String privilege;

  /// Registration date, 注册时间.
  final String registrationDate;

  /// Where the user comes from, 来自.
  final String? comeFrom;

  /// Whether the user is online now, 状态.
  final bool online;

  /// The stat bar labels and the fields they fill.
  ///
  /// Kept explicit so the parsing rules are visible and testable.
  static const statLabels = <String>[
    'UID:',
    '头衔:',
    '精华:',
    '主题:',
    '帖子:',
    '威望:',
    '天使币:',
    '宣传度:',
    '天然°:',
    '腹黑°:',
    '精灵:',
    'CP:',
    '阅读权限:',
    '注册时间:',
    '来自:',
  ];

  /// Special attributes that change over time, mapped to the stored name.
  static const specialAttrLabels = <String, String>{
    '龙之印章:': '龙之印章',
    '西瓜:': '西瓜',
    '爱心❤:': '爱心',
    '金蛋:': '金蛋',
    '魔法石:': '魔法石',
  };

  /// Build a profile from a `<td id="userinfo_${UID}">` node.
  ///
  /// Returns null when the post id or the stat bar is missing, as the source
  /// does. Missing single fields fall back to an empty string.
  static TsdmUserBriefProfile? buildFromUserProfileNode(dom.Element element) {
    final postId = element.id.split('_').lastOrNull;
    if (postId == null || postId.isEmpty) {
      return null;
    }

    final avatarNode = element.q('div#ts_avatar_$postId');
    if (avatarNode == null) {
      return null;
    }

    final username = avatarNode.q('div:nth-child(1)')?.text;
    // Allow an empty value.
    final nickname = avatarNode.q('div:nth-child(2)')?.text;
    final avatarUrl = avatarNode.q('div.avatar > a > img')?.imageUrl();

    final statBarNode = element.q('div.tsdm_statbar');
    if (statBarNode == null) {
      return null;
    }

    final firstStatNode = statBarNode.children.firstOrNull;
    final userGroup = firstStatNode?.text.trim();
    final userGroupColor = TsdmCssColor.toColor(
      firstStatNode?.q('font')?.attributes['color'],
    );

    var uid = '';
    var title = '';
    var recommended = '';
    var threadCount = '';
    var postCount = '';
    var famous = '';
    var coins = '';
    var publicity = '';
    var natural = '';
    var scheming = '';
    var spirit = '';
    var specialAttr = '';
    var specialAttrName = '';
    var couple = '';
    var privilege = '';
    var registrationDate = '';
    String? comeFrom;

    // The stat bar holds label nodes and value nodes in sequence; the source
    // pairs them with `slices(2)`.
    for (final pair in statBarNode.qAll('> span').slices(2)) {
      if (pair.length < 2) {
        continue;
      }
      final data = pair[1].text;
      final label = pair[0].text;
      switch (label) {
        case 'UID:':
          uid = data;
        case '头衔:':
          title = data;
        case '精华:':
          recommended = data;
        case '主题:':
          threadCount = data;
        case '帖子:':
          postCount = data;
        case '威望:':
          famous = data;
        case '天使币:':
          coins = data;
        case '宣传度:':
          publicity = data;
        case '天然°:':
          natural = data;
        case '腹黑°:':
          scheming = data;
        case '精灵:':
          spirit = data;
        case 'CP:':
          couple = data;
        case '阅读权限:':
          privilege = data;
        case '注册时间:':
          registrationDate = data;
        case '来自:':
          comeFrom = data;
        default:
          final specialName = specialAttrLabels[label];
          if (specialName != null) {
            specialAttr = data;
            specialAttrName = specialName;
          }
      }
    }

    final online =
        statBarNode.q('div > a')?.attributes['title']?.contains('在线') ?? false;

    return TsdmUserBriefProfile(
      username: username ?? '',
      avatarUrl: avatarUrl,
      uid: uid,
      nickname: nickname,
      userGroup: userGroup ?? '',
      userGroupColor: userGroupColor,
      title: title,
      recommended: recommended,
      threadCount: threadCount,
      postCount: postCount,
      famous: famous,
      coins: coins,
      publicity: publicity,
      natural: natural,
      scheming: scheming,
      spirit: spirit,
      specialAttr: specialAttr,
      specialAttrName: specialAttrName,
      couple: couple,
      privilege: privilege,
      registrationDate: registrationDate,
      comeFrom: comeFrom,
      online: online,
    );
  }
}
