import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cache_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_home_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_login_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_mine_page.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterHomePage].
class EyepetizerFlutterHomePageState extends State<EyepetizerFlutterHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('开眼 · 登录 / 个人 / 社区')),
      body: ListView(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Text(
              '影单模块之外的四个界面：账号、个人主页、社区与本地缓存。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('登录 / 注册'),
            subtitle: const Text('account.kaiyanapp.com'),
            onTap: () => _push(const EyepetizerFlutterLoginPage()),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('我的'),
            subtitle: const Text('个人资料、收藏、观看记录入口'),
            onTap: () => _push(const EyepetizerFlutterMinePage()),
          ),
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('社区'),
            subtitle: const Text('推荐 / 关注'),
            onTap: () => _push(const EyepetizerFlutterCommunityPage()),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('本地缓存'),
            subtitle: const Text('sqflite 中的 discover / daily / recommend'),
            onTap: () => _push(const EyepetizerFlutterCachePage()),
          ),
        ],
      ),
    );
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
