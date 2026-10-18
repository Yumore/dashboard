import 'package:flutter/material.dart';

import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_more_info_page.dart';
import 'flutterwechatfull_remote_image.dart';
import 'flutterwechatfull_style.dart';
import 'flutterwechatfull_user_info_page.dart';

/// 个人信息 rows; only 更多 navigates in the source, the rest are inert.
class FlutterWechatFullUserInfoPageState
    extends State<FlutterWechatFullUserInfoPage> {
  void _openMoreInfo() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FlutterWechatFullMoreInfoPage(),
      ),
    );
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
          '个人信息',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                _buildAvatarRow(),
                _buildDivider(),
                _buildTextRow('名字', FlutterWechatFullDemoData.profileName),
                _buildDivider(),
                _buildTextRow(
                  '微信号',
                  FlutterWechatFullDemoData.profileWechatIdValue,
                  trailingIcon: true,
                ),
                _buildDivider(),
                _buildQrRow(),
                _buildDivider(),
                _buildTextRow('更多', '', onTap: _openMoreInfo),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Container(color: Colors.white, child: _buildTextRow('我的地址', '')),
        ],
      ),
    );
  }

  Widget _buildAvatarRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              '头像',
              style: TextStyle(
                fontSize: 17.0,
                color: FlutterWechatFullStyle.textPrimary,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: FlutterWechatFullRemoteImage(
              url: FlutterWechatFullDemoData.profileAvatarUrl,
              width: 66.0,
              height: 66.0,
            ),
          ),
          const SizedBox(width: 16.0),
          FlutterWechatFullLocalImage(
            path: FlutterWechatFullImages.arrow,
            width: 8.0,
            height: 13.0,
          ),
        ],
      ),
    );
  }

  Widget _buildTextRow(
    String title,
    String subtitle, {
    bool trailingIcon = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: SizedBox(
        height: 56.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17.0,
                  color: FlutterWechatFullStyle.textPrimary,
                ),
              ),
              const SizedBox(width: 32.0),
              Expanded(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17.0,
                    color: FlutterWechatFullStyle.textSecondary,
                  ),
                ),
              ),
              if (trailingIcon) ...<Widget>[
                const SizedBox(width: 8.0),
                FlutterWechatFullLocalImage(
                  path: FlutterWechatFullImages.arrow,
                  width: 8.0,
                  height: 13.0,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrRow() {
    return SizedBox(
      height: 56.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                '我的二维码',
                style: TextStyle(
                  fontSize: 17.0,
                  color: FlutterWechatFullStyle.textPrimary,
                ),
              ),
            ),
            FlutterWechatFullLocalImage(
              path: FlutterWechatFullImages.qrCode,
              width: 18.0,
              height: 18.0,
            ),
            const SizedBox(width: 8.0),
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

  Widget _buildDivider() {
    return const Divider(
      height: 0.5,
      indent: 16.0,
      color: FlutterWechatFullStyle.rowDivider,
    );
  }
}
