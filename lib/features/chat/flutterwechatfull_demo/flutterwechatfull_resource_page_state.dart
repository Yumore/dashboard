import 'package:flutter/material.dart';

import 'flutterwechatfull_resource_page.dart';
import 'flutterwechatfull_style.dart';
import 'flutterwechatfull_switch_group.dart';

/// Auto-download / 照片 / 视频 / 移动网络下视频自动播放, each under its source
/// explanatory header.
class FlutterWechatFullResourcePageState
    extends State<FlutterWechatFullResourcePage> {
  final Map<String, bool> _autoDownload = <String, bool>{'自动下载': true};
  final Map<String, bool> _saveToAlbum = <String, bool>{'照片': true, '视频': true};
  final Map<String, bool> _autoPlay = <String, bool>{'移动网络下视频自动播放': false};

  void _toggle(Map<String, bool> group, String title, bool value) {
    setState(() => group[title] = value);
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
          '照片、视频和文件',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullSwitchGroup(
            header: '在其他设备查看的照片、视频和文件在手机上自动下载',
            values: _autoDownload,
            onChanged: (String title, bool value) =>
                _toggle(_autoDownload, title, value),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullSwitchGroup(
            header: '拍摄或编辑后的内容保存到系统相册',
            values: _saveToAlbum,
            onChanged: (String title, bool value) =>
                _toggle(_saveToAlbum, title, value),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullSwitchGroup(
            header: '开启后，朋友圈视频在移动网络下自动播放',
            values: _autoPlay,
            onChanged: (String title, bool value) =>
                _toggle(_autoPlay, title, value),
          ),
        ],
      ),
    );
  }
}
