import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutterwechatfull_action_sheet.dart';
import 'flutterwechatfull_contact.dart';
import 'flutterwechatfull_contact_info_page.dart';
import 'flutterwechatfull_contact_more_info_page.dart';
import 'flutterwechatfull_contact_setting_info_page.dart';
import 'flutterwechatfull_friend_permission_page.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_photo_browser_page.dart';
import 'flutterwechatfull_remote_image.dart';
import 'flutterwechatfull_style.dart';

/// Contact detail: header, 备注和标签, 朋友权限, the 朋友圈 thumbnails, 更多信息
/// and the two bottom actions. 发消息 is dead in the source and stays dead.
class FlutterWechatFullContactInfoPageState
    extends State<FlutterWechatFullContactInfoPage> {
  FlutterWechatFullContact get _contact => widget.contact;

  void _openSettings() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            FlutterWechatFullContactSettingInfoPage(contact: _contact),
      ),
    );
  }

  void _openMoreInfo() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FlutterWechatFullContactMoreInfoPage(contact: _contact),
      ),
    );
  }

  void _openFriendPermission() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            FlutterWechatFullFriendPermissionPage(contact: _contact),
      ),
    );
  }

  void _showCallSheet() {
    FlutterWechatFullActionSheet.show(
      context,
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('视频通话'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('语音通话'),
        ),
      ],
    );
  }

  void _openPhotoBrowser(int index) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FlutterWechatFullPhotoBrowserPage(
          photos: <String>[
            for (final picture in _contact.pictures) picture.bigUrl,
          ],
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: <Widget>[
          InkWell(
            onTap: _openSettings,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: FlutterWechatFullLocalImage(
                path: FlutterWechatFullImages.more,
                width: 24.0,
                height: 24.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildHeader(),
          const Divider(
            height: 0.5,
            indent: 16.0,
            color: FlutterWechatFullStyle.rowDivider,
          ),
          _buildRemarkRow(),
          const Divider(
            height: 0.5,
            indent: 16.0,
            color: FlutterWechatFullStyle.rowDivider,
          ),
          _buildArrowRow('朋友权限', _openFriendPermission),
          const SizedBox(height: 8.0),
          _buildMoments(),
          _buildArrowRow('更多信息', _openMoreInfo),
          const SizedBox(height: 8.0),
          _buildActionRow('发消息', FlutterWechatFullImages.messageBlue, () {}),
          const Divider(
            height: 0.5,
            indent: 16.0,
            color: FlutterWechatFullStyle.rowDivider,
          ),
          _buildActionRow(
            '音视频通话',
            FlutterWechatFullImages.videoCallBlue,
            _showCallSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: FlutterWechatFullRemoteImage(
              url: _contact.avatarUrl,
              width: 64.0,
              height: 64.0,
            ),
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        _contact.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: FlutterWechatFullStyle.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    FlutterWechatFullLocalImage(
                      path: _contact.isFemale
                          ? FlutterWechatFullImages.female
                          : FlutterWechatFullImages.male,
                      width: 18.0,
                      height: 18.0,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  '昵称：${_contact.remarks.isEmpty ? _contact.name : _contact.remarks}',
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Color(0xFF808080),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '微信号：${_contact.wechatId}',
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Color(0xFF808080),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkRow() {
    return SizedBox(
      height: 56.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                '备注和标签',
                style: TextStyle(
                  fontSize: 16.0,
                  color: FlutterWechatFullStyle.textPrimary,
                ),
              ),
            ),
            FlutterWechatFullLocalImage(
              path: FlutterWechatFullImages.arrow,
              width: 8.0,
              height: 13.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowRow(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: FlutterWechatFullStyle.textPrimary,
                  ),
                ),
              ),
              FlutterWechatFullLocalImage(
                path: FlutterWechatFullImages.arrow,
                width: 8.0,
                height: 13.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoments() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '朋友圈',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: FlutterWechatFullStyle.textPrimary,
                  ),
                ),
              ),
              FlutterWechatFullLocalImage(
                path: FlutterWechatFullImages.arrow,
                width: 8.0,
                height: 13.0,
              ),
            ],
          ),
          if (_contact.pictures.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10.0),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double size = (constraints.maxWidth - 16.0) / 3;
                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: <Widget>[
                    for (
                      int index = 0;
                      index < _contact.pictures.length;
                      index++
                    )
                      GestureDetector(
                        onTap: () => _openPhotoBrowser(index),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: FlutterWechatFullRemoteImage(
                            url: _contact.pictures[index].smallUrl,
                            width: size,
                            height: size,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionRow(String label, String icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlutterWechatFullLocalImage(path: icon, width: 20.0, height: 20.0),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF576B95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
