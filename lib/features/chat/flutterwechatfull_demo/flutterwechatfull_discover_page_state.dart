import 'package:flutter/material.dart';

import 'flutterwechatfull_discover_page.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_moments_page.dart';
import 'flutterwechatfull_style.dart';

/// Mirrors `DiscoverPage`. Only 朋友圈 has a `onTap` in the source; every other
/// row is dead and stays dead here.
class FlutterWechatFullDiscoverPageState
    extends State<FlutterWechatFullDiscoverPage> {
  static final List<List<(String, String)>> _groups = <List<(String, String)>>[
    <(String, String)>[('朋友圈', FlutterWechatFullImages.moments)],
    <(String, String)>[
      ('扫一扫', FlutterWechatFullImages.scan),
      ('摇一摇', FlutterWechatFullImages.shake),
    ],
    <(String, String)>[
      ('看一看', FlutterWechatFullImages.look),
      ('搜一搜', FlutterWechatFullImages.search),
    ],
    <(String, String)>[
      ('附近的人', FlutterWechatFullImages.nearby),
      ('漂流瓶', FlutterWechatFullImages.bottle),
    ],
    <(String, String)>[
      ('购物', FlutterWechatFullImages.shopping),
      ('游戏', FlutterWechatFullImages.game),
    ],
    <(String, String)>[('小程序', FlutterWechatFullImages.miniProgram)],
  ];

  void _openMoments() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FlutterWechatFullMomentsPage(),
      ),
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
          '发现',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181818),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: <Widget>[
          for (final List<(String, String)> group in _groups) ...<Widget>[
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  for (
                    int index = 0;
                    index < group.length;
                    index++
                  ) ...<Widget>[
                    _buildRow(group[index], index == 0),
                    if (index != group.length - 1)
                      const Divider(
                        height: 0.5,
                        indent: 52.0,
                        color: FlutterWechatFullStyle.rowDivider,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ],
      ),
    );
  }

  Widget _buildRow((String, String) entry, bool isMoments) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: isMoments ? _openMoments : () {},
        child: SizedBox(
          height: 56.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                FlutterWechatFullLocalImage(
                  path: entry.$2,
                  width: 24.0,
                  height: 24.0,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    entry.$1,
                    style: const TextStyle(
                      fontSize: 17.0,
                      color: FlutterWechatFullStyle.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
