import 'dart:async';

import 'package:flutter/material.dart';

import 'flutterwechatfull_check_scope_page.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_style.dart';

/// 最近三天 / 最近一个月 / 最近半年 / 全部; picking one shows the source's 1s
/// loading dialog and then pops the chosen value.
class FlutterWechatFullCheckScopePageState
    extends State<FlutterWechatFullCheckScopePage> {
  static const List<String> _scopes = <String>['最近三天', '最近一个月', '最近半年', '全部'];

  late String _selected = widget.value;

  void _select(String value) {
    setState(() => _selected = value);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(
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
      Navigator.of(context).pop(value);
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
          '允许朋友查看朋友圈的范围',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              footer: '在选择的事件范围之前发布的朋友圈，将对朋友不可见',
              items: <FlutterWechatFullListTile>[
                for (final String scope in _scopes)
                  FlutterWechatFullListTile(
                    title: scope,
                    showArrow: false,
                    onTap: () => _select(scope),
                    trailing: scope == _selected
                        ? FlutterWechatFullLocalImage(
                            path: FlutterWechatFullImages.selectedCheck,
                            width: 20.0,
                            height: 20.0,
                          )
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
