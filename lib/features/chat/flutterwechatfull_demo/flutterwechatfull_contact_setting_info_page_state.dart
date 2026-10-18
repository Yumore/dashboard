import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutterwechatfull_action_sheet.dart';
import 'flutterwechatfull_contact.dart';
import 'flutterwechatfull_contact_setting_info_page.dart';
import 'flutterwechatfull_friend_permission_page.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_style.dart';

/// Mirrors 资料设置: 备注, 朋友权限, 星标 / 黑名单 switches, 投诉 (dead) and the
/// red 删除 row whose action sheet only closes itself.
class FlutterWechatFullContactSettingInfoPageState
    extends State<FlutterWechatFullContactSettingInfoPage> {
  bool _starred = false;
  bool _blocked = false;

  FlutterWechatFullContact get _contact => widget.contact;

  String get _pronoun => _contact.isFemale ? '她' : '他';

  void _openFriendPermission() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            FlutterWechatFullFriendPermissionPage(contact: _contact),
      ),
    );
  }

  void _showDeleteSheet() {
    FlutterWechatFullActionSheet.show(
      context,
      title: '将联系人“${_contact.name}”删除，同时删除与该联系人的聊天记录',
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('删除联系人'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          '资料设置',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '设置备注和标签',
                  subtitle: _contact.nickname,
                  subtitleInline: true,
                ),
                FlutterWechatFullListTile(
                  title: '朋友权限',
                  onTap: _openFriendPermission,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '把$_pronoun推荐给朋友',
                  subtitle: '由于隐私设置，无法推荐',
                  showArrow: false,
                  onTap: () {},
                ),
                FlutterWechatFullListTile(
                  title: '设为星标朋友',
                  showArrow: false,
                  trailing: CupertinoSwitch(
                    value: _starred,
                    activeTrackColor: const Color(0xFF57BE6A),
                    onChanged: (bool value) => setState(() => _starred = value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '加入黑名单',
                  showArrow: false,
                  trailing: CupertinoSwitch(
                    value: _blocked,
                    activeTrackColor: const Color(0xFF57BE6A),
                    onChanged: (bool value) => setState(() => _blocked = value),
                  ),
                ),
                FlutterWechatFullListTile(title: '投诉', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '删除',
                  center: true,
                  showArrow: false,
                  titleColor: FlutterWechatFullStyle.warning,
                  onTap: _showDeleteSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
