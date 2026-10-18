import 'package:flutter/material.dart';

import 'flutterwechatfull_account_security_page.dart';
import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_more_security_setting_page.dart';
import 'flutterwechatfull_style.dart';

/// 账号与安全 groups exactly as the source orders them.
class FlutterWechatFullAccountSecurityPageState
    extends State<FlutterWechatFullAccountSecurityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '账号与安全',
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
                  title: '微信号',
                  subtitle: FlutterWechatFullDemoData.profileWechatIdValue,
                  subtitleInline: true,
                  showArrow: false,
                  onTap: () {},
                ),
                const FlutterWechatFullListTile(
                  title: '手机号',
                  subtitle: '未绑定',
                  subtitleInline: true,
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
                  title: '微信密码',
                  subtitle: '已设置',
                  subtitleInline: true,
                  onTap: () {},
                ),
                FlutterWechatFullListTile(
                  title: '声音锁',
                  subtitle: '未设置',
                  subtitleInline: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(title: '应急联系人', onTap: () {}),
                FlutterWechatFullListTile(title: '登录设备管理', onTap: () {}),
                FlutterWechatFullListTile(
                  title: '更多安全设置',
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const FlutterWechatFullMoreSecuritySettingPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(title: '帮朋友冻结微信', onTap: () {}),
                FlutterWechatFullListTile(title: '微信安全中心', onTap: () {}),
              ],
              footer: '如果遇到账号信息泄露、忘记密码、诈骗等账号安全问题，可前往微信安全中心。',
              footerHeight: 8.0,
            ),
          ),
        ],
      ),
    );
  }
}
