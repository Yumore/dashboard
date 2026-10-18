import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutterwechatfull_contact.dart';
import 'flutterwechatfull_friend_permission_page.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_style.dart';

/// 朋友权限: the two permission radios, then the 朋友圈 switches that the source
/// hides for 1s (loading dialog) when 仅聊天 is chosen.
class FlutterWechatFullFriendPermissionPageState
    extends State<FlutterWechatFullFriendPermissionPage> {
  static const String _all = '聊天、朋友圈、微信运动等';
  static const String _chatOnly = '仅聊天';

  String _permission = _all;
  bool _hideMine = false;
  bool _hideTheirs = false;
  bool _switchesVisible = true;

  FlutterWechatFullContact get _contact => widget.contact;

  String get _pronoun => _contact.isFemale ? '她' : '他';

  void _selectPermission(String value) {
    if (value == _all) {
      setState(() {
        _permission = value;
        _switchesVisible = true;
      });
      return;
    }
    setState(() => _permission = value);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const Center(
        child: SizedBox(
          width: 96.0,
          height: 96.0,
          child: Card(child: Center(child: CircularProgressIndicator())),
        ),
      ),
    );
    Timer(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => _switchesVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '朋友权限',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              header: '设置朋友权限',
              items: <FlutterWechatFullListTile>[
                _buildRadio(_all),
                _buildRadio(_chatOnly),
              ],
            ),
          ),
          if (_switchesVisible) ...<Widget>[
            const SizedBox(height: 8.0),
            FlutterWechatFullGroupView(
              group: FlutterWechatFullGroup(
                header: '朋友圈和视频动态',
                headerHeight: 0.0,
                items: <FlutterWechatFullListTile>[
                  FlutterWechatFullListTile(
                    title: '不$_pronoun看我的朋友圈',
                    showArrow: false,
                    trailing: CupertinoSwitch(
                      value: _hideMine,
                      activeTrackColor: const Color(0xFF57BE6A),
                      onChanged: (bool value) =>
                          setState(() => _hideMine = value),
                    ),
                  ),
                  FlutterWechatFullListTile(
                    title: '不看$_pronoun的朋友圈',
                    showArrow: false,
                    trailing: CupertinoSwitch(
                      value: _hideTheirs,
                      activeTrackColor: const Color(0xFF57BE6A),
                      onChanged: (bool value) =>
                          setState(() => _hideTheirs = value),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  FlutterWechatFullListTile _buildRadio(String value) {
    return FlutterWechatFullListTile(
      title: value,
      showArrow: false,
      onTap: () => _selectPermission(value),
      trailing: value == _permission
          ? FlutterWechatFullLocalImage(
              path: FlutterWechatFullImages.selectedCheck,
              width: 20.0,
              height: 20.0,
            )
          : null,
    );
  }
}
