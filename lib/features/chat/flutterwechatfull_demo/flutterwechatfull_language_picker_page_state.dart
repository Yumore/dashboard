import 'package:flutter/material.dart';

import 'flutterwechatfull_bar_button.dart';
import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_language_picker_page.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_style.dart';

/// One selectable row per bundled language; 完成 pops the selection.
class FlutterWechatFullLanguagePickerPageState
    extends State<FlutterWechatFullLanguagePickerPage> {
  late String _selected = widget.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        title: const Text(
          '设置语言',
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
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                for (final String language
                    in FlutterWechatFullDemoData.languages)
                  FlutterWechatFullListTile(
                    title: language,
                    showArrow: false,
                    titleColor: language == _selected
                        ? FlutterWechatFullStyle.primary
                        : FlutterWechatFullStyle.textPrimary,
                    onTap: () => setState(() => _selected = language),
                    trailing: language == _selected
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
