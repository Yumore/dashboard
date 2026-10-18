import 'package:flutter/material.dart';

import 'flutterwechatfull_bar_button.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_setting_gender_page.dart';
import 'flutterwechatfull_style.dart';

/// Pops the chosen gender string; 取消 pops null.
class FlutterWechatFullSettingGenderPageState
    extends State<FlutterWechatFullSettingGenderPage> {
  late String _selected = widget.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.0,
        title: const Text(
          '设置性别',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
        leading: FlutterWechatFullBarButton(
          label: '取消',
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 88.0,
        actions: <Widget>[
          FlutterWechatFullBarButton(
            label: '完成',
            onPressed: () => Navigator.of(context).pop(_selected),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                for (final String gender in <String>['男', '女'])
                  Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () => setState(() => _selected = gender),
                      child: SizedBox(
                        height: 56.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  gender,
                                  style: const TextStyle(
                                    fontSize: 17.0,
                                    color: FlutterWechatFullStyle.textPrimary,
                                  ),
                                ),
                              ),
                              if (gender == _selected)
                                FlutterWechatFullLocalImage(
                                  path: FlutterWechatFullImages.selectedCheck,
                                  width: 20.0,
                                  height: 20.0,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
