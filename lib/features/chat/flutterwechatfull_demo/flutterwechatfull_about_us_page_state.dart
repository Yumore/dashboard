import 'package:flutter/material.dart';

import 'flutterwechatfull_about_us_page.dart';
import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_style.dart';

/// Icon + version header, four dead rows, and the Tencent copyright footer.
class FlutterWechatFullAboutUsPageState
    extends State<FlutterWechatFullAboutUsPage> {
  static const List<String> _rows = <String>['去评分', '功能介绍', '投诉', '版本更新'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const SizedBox.shrink(),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildHeader(),
          for (int index = 0; index < _rows.length; index++) ...<Widget>[
            _buildRow(_rows[index]),
            if (index != _rows.length - 1)
              const Divider(
                height: 0.5,
                indent: 40.0,
                endIndent: 40.0,
                color: FlutterWechatFullStyle.rowDivider,
              ),
          ],
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 0.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: FlutterWechatFullStyle.divider, width: 0.5),
        ),
      ),
      child: Column(
        children: <Widget>[
          FlutterWechatFullLocalImage(
            path: FlutterWechatFullImages.aboutIcon,
            width: 64.0,
            height: 64.0,
          ),
          const SizedBox(height: 30.0),
          const Text(
            '微信 WeChat',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          Text(
            FlutterWechatFullDemoData.aboutVersion,
            style: const TextStyle(
              fontSize: 16.0,
              color: FlutterWechatFullStyle.textSecondary,
            ),
          ),
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }

  Widget _buildRow(String title) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {},
        child: SizedBox(
          height: 50.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17.0,
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
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 20.0),
      child: Column(
        children: <Widget>[
          const Text(
            '《微信软件许可及服务协议》和《微信隐私保护指引》',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.0, color: Color(0xFF576B95)),
          ),
          const SizedBox(height: 15.0),
          const Text(
            '腾讯公司 版权所有',
            style: TextStyle(
              fontSize: 12.0,
              color: FlutterWechatFullStyle.textHint,
            ),
          ),
          const SizedBox(height: 2.0),
          const Text(
            'Copyright © 2011-2019 Tencent.All Rights Reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.0,
              color: FlutterWechatFullStyle.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
