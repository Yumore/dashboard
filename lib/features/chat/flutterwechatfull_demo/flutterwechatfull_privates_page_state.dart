import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutterwechatfull_add_way_page.dart';
import 'flutterwechatfull_check_scope_page.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_privates_page.dart';
import 'flutterwechatfull_style.dart';

/// 隐私: verification switch, 添加我的方式, blacklist, the 朋友圈和视频动态 group
/// (with the scope row writing the picked value back) and 授权管理.
class FlutterWechatFullPrivatesPageState
    extends State<FlutterWechatFullPrivatesPage> {
  bool _needVerify = true;
  bool _recommendContacts = true;
  bool _strangerMoments = false;
  bool _momentsAlert = true;
  String _scope = '全部';

  Future<void> _pickScope() async {
    final String? value = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => FlutterWechatFullCheckScopePage(value: _scope),
      ),
    );
    if (value != null && mounted) {
      setState(() => _scope = value);
    }
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
          '隐私',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                _switchTile(
                  '加我为朋友时需要验证',
                  _needVerify,
                  (bool value) => setState(() => _needVerify = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              footer: '开启后，为你推荐已经开通微信的手机联系人。',
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '添加我的方式',
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const FlutterWechatFullAddWayPage(),
                    ),
                  ),
                ),
                _switchTile(
                  '向我推荐通讯录朋友',
                  _recommendContacts,
                  (bool value) => setState(() => _recommendContacts = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                const FlutterWechatFullListTile(title: '通讯录黑名单', onTap: null),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              header: '朋友圈和视频动态',
              items: <FlutterWechatFullListTile>[
                const FlutterWechatFullListTile(
                  title: '不让他(她)看我的朋友圈',
                  onTap: null,
                ),
                const FlutterWechatFullListTile(
                  title: '不看他(她)的朋友圈',
                  onTap: null,
                ),
                FlutterWechatFullListTile(
                  title: '允许朋友查看朋友圈的范围',
                  subtitle: _scope,
                  subtitleInline: true,
                  onTap: _pickScope,
                ),
                _switchTile(
                  '允许陌生人查看十条朋友圈',
                  _strangerMoments,
                  (bool value) => setState(() => _strangerMoments = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              footer: '关闭后，有朋友发表朋友圈时，界面下方的”发现“切换按钮上不在出现红点提示',
              items: <FlutterWechatFullListTile>[
                _switchTile(
                  '朋友圈更新提醒',
                  _momentsAlert,
                  (bool value) => setState(() => _momentsAlert = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                const FlutterWechatFullListTile(title: '授权管理', onTap: null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  FlutterWechatFullListTile _switchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return FlutterWechatFullListTile(
      title: title,
      showArrow: false,
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: const Color(0xFF57BE6A),
        onChanged: onChanged,
      ),
    );
  }
}
