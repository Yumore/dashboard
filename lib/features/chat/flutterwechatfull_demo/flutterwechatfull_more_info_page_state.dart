import 'package:flutter/material.dart';

import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_more_info_page.dart';
import 'flutterwechatfull_setting_gender_page.dart';
import 'flutterwechatfull_signature_page.dart';
import 'flutterwechatfull_style.dart';

/// 更多信息: both editable rows write the returned value back, like the source.
class FlutterWechatFullMoreInfoPageState
    extends State<FlutterWechatFullMoreInfoPage> {
  String _gender = '男';
  String _signature = FlutterWechatFullDemoData.profileSignature;

  Future<void> _pickGender() async {
    final String? value = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => FlutterWechatFullSettingGenderPage(value: _gender),
      ),
    );
    if (value != null && mounted) {
      setState(() => _gender = value);
    }
  }

  Future<void> _editSignature() async {
    final String? value = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => FlutterWechatFullSignaturePage(text: _signature),
      ),
    );
    if (value != null && mounted) {
      setState(() => _signature = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        title: const SizedBox.shrink(),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                _buildRow('性别', _gender, _pickGender),
                _buildDivider(),
                _buildRow('地址', '广东 深圳', () {}),
                _buildDivider(),
                _buildRow('个性签名', _signature, _editSignature),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17.0,
                  color: FlutterWechatFullStyle.textPrimary,
                ),
              ),
              const SizedBox(width: 32.0),
              Expanded(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17.0,
                    color: FlutterWechatFullStyle.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              FlutterWechatFullLocalImage(
                path: FlutterWechatFullImages.arrow,
                width: 8.0,
                height: 13.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 0.5,
      indent: 16.0,
      color: FlutterWechatFullStyle.rowDivider,
    );
  }
}
