import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutterwechatfull_chat_background_page.dart';
import 'flutterwechatfull_chat_record_backup_page.dart';
import 'flutterwechatfull_discover_manager_page.dart';
import 'flutterwechatfull_general_page.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_language_picker_page.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_resource_page.dart';
import 'flutterwechatfull_style.dart';

/// 通用: language row writes the picked value back; every source row is here.
class FlutterWechatFullGeneralPageState
    extends State<FlutterWechatFullGeneralPage> {
  String _language = '简体中文';
  bool _receiverMode = false;

  Future<void> _pickLanguage() async {
    final String? value = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => FlutterWechatFullLanguagePickerPage(value: _language),
      ),
    );
    if (value != null && mounted) {
      setState(() => _language = value);
    }
  }

  void _push(Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
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
          '通用',
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
                  title: '多语言',
                  subtitle: _language,
                  subtitleInline: true,
                  onTap: _pickLanguage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(title: '字体大小', onTap: () {}),
                FlutterWechatFullListTile(
                  title: '聊天背景',
                  onTap: () =>
                      _push(const FlutterWechatFullChatBackgroundPage()),
                ),
                FlutterWechatFullListTile(title: '我的表情', onTap: () {}),
                FlutterWechatFullListTile(
                  title: '照片、视频和文件',
                  onTap: () => _push(const FlutterWechatFullResourcePage()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '听筒模式',
                  showArrow: false,
                  trailing: CupertinoSwitch(
                    value: _receiverMode,
                    activeTrackColor: const Color(0xFF57BE6A),
                    onChanged: (bool value) =>
                        setState(() => _receiverMode = value),
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
                  title: '发现页管理',
                  onTap: () =>
                      _push(const FlutterWechatFullDiscoverManagerPage()),
                ),
                FlutterWechatFullListTile(title: '辅助功能', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '聊天记录备份与迁移',
                  onTap: () =>
                      _push(const FlutterWechatFullChatRecordBackupPage()),
                ),
                FlutterWechatFullListTile(title: '存储空间', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '清空聊天记录',
                  center: true,
                  showArrow: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
