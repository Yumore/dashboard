import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutterwechatfull_about_us_page.dart';
import 'flutterwechatfull_account_security_page.dart';
import 'flutterwechatfull_action_sheet.dart';
import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_general_page.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_loading_dialog.dart';
import 'flutterwechatfull_login_page.dart';
import 'flutterwechatfull_message_notify_page.dart';
import 'flutterwechatfull_privates_page.dart';
import 'flutterwechatfull_setting_page.dart';
import 'flutterwechatfull_style.dart';

/// Mirrors the six setting groups; only 插件 and 切换账号 are dead in the source,
/// and 退出登录 shows a 1s loading dialog before returning to 登录.
class FlutterWechatFullSettingPageState
    extends State<FlutterWechatFullSettingPage> {
  void _push(Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _showLogoutSheet() {
    FlutterWechatFullActionSheet.show(
      context,
      message: '退出后不会删除任何历史数据，下次登录依然可以使用本账号',
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(context).pop();
            _logout();
          },
          child: const Text('退出登录'),
        ),
      ],
    );
  }

  void _logout() {
    FlutterWechatFullLoadingDialog.simulate(
      context,
      onFinished: () {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const FlutterWechatFullLoginPage(),
          ),
          (Route<dynamic> route) => false,
        );
      },
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
          '设置',
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
                  title: '账号与安全',
                  onTap: () =>
                      _push(const FlutterWechatFullAccountSecurityPage()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '新消息通知',
                  onTap: () =>
                      _push(const FlutterWechatFullMessageNotifyPage()),
                ),
                FlutterWechatFullListTile(
                  title: '隐私',
                  onTap: () => _push(const FlutterWechatFullPrivatesPage()),
                ),
                FlutterWechatFullListTile(
                  title: '通用',
                  onTap: () => _push(const FlutterWechatFullGeneralPage()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '帮助与反馈',
                  showArrow: false,
                  onTap: () {},
                ),
                FlutterWechatFullListTile(
                  title: '关于微信',
                  subtitle: FlutterWechatFullDemoData.appVersion,
                  subtitleInline: true,
                  onTap: () => _push(const FlutterWechatFullAboutUsPage()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '插件',
                  icon: FlutterWechatFullImages.labLogo,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                const FlutterWechatFullListTile(
                  title: '切换账号',
                  center: true,
                  showArrow: false,
                  onTap: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '退出登录',
                  center: true,
                  showArrow: false,
                  onTap: _showLogoutSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
