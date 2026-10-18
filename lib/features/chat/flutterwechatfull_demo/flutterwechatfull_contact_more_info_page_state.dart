import 'package:flutter/material.dart';

import 'flutterwechatfull_contact.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_style.dart';

import 'flutterwechatfull_contact_more_info_page.dart';

class FlutterWechatFullContactMoreInfoPageState
    extends State<FlutterWechatFullContactMoreInfoPage> {
  @override
  Widget build(BuildContext context) {
    final FlutterWechatFullContact contact = widget.contact;
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '社交资料',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                const FlutterWechatFullListTile(
                  title: '我和他(她)的共同群聊',
                  subtitle: '0个',
                  subtitleInline: true,
                  onTap: null,
                ),
                if (contact.featureSign.isNotEmpty)
                  FlutterWechatFullListTile(
                    title: '个性签名',
                    subtitle: contact.featureSign,
                    showArrow: false,
                  ),
                const FlutterWechatFullListTile(
                  title: '来源',
                  subtitle: '通过搜索手机号添加',
                  showArrow: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
