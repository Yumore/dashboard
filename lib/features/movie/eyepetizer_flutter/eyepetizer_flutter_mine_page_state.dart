import 'dart:async';

import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cover_image_widget.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_layout.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_login.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_login_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_mine_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_main_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_prefs_key.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_prefs_util.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// State for [EyepetizerFlutterMinePage].
///
/// The source rebuilt this screen from a `StreamBuilder<Member>` fed by
/// `MineBloc.getUserData`. There is no bloc in the port, so the screen reads
/// `user_data` directly and re-reads it after the login route resolves — the
/// source's `LoginEvent` effect, without an event bus.
class EyepetizerFlutterMinePageState extends State<EyepetizerFlutterMinePage>
    with AutomaticKeepAliveClientMixin {
  EyepetizerFlutterLogin? _login;
  String? _version;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    unawaited(loadUserData());
    unawaited(loadVersion());
  }

  /// `MineBloc.getUserData` — `user_data` decoded as a `Login`; a missing or
  /// empty entry leaves the screen signed out.
  Future<void> loadUserData() async {
    final login =
        await EyepetizerFlutterPrefsUtil.getObj<EyepetizerFlutterLogin>(
          EyepetizerFlutterPrefsKey.userData,
          EyepetizerFlutterLogin.fromJson,
        );
    if (!mounted) return;
    setState(() => _login = login);
  }

  /// `MineBloc.getVersion` — `PackageInfo.fromPlatform().version`, shown as
  /// `Version <v>` and falling back to `Unknown`.
  Future<void> loadVersion() async {
    var version = 'Unknown';
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
    } catch (error) {
      version = 'Unknown';
    }
    if (!mounted) return;
    setState(() => _version = version);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final member = _login?.member;
    final nick = member?.nick;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () => unawaited(_openProfile()),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: EyepetizerFlutterCoverImageWidget(
                  imageUrl: member?.avatar,
                  width: 60,
                  height: 60,
                  borderRadius: 100,
                ),
              ),
            ),
            Visibility(
              visible: member != null && (nick ?? '').isNotEmpty,
              child: InkWell(
                onTap: () => unawaited(_openProfile()),
                child: Column(
                  children: <Widget>[
                    Text(
                      nick ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '查看个人主页',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: member == null,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  '点击登录即可评论及发布内容',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
            Row(
              children: const <Widget>[
                Expanded(
                  child: _MineShortcut(icon: Icons.store, label: '收藏'),
                ),
                Expanded(
                  child: _MineShortcut(icon: Icons.cached, label: '缓存'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: EyepetizerFlutterItemLayout(title: '我的关注'),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: EyepetizerFlutterItemLayout(title: '观看记录'),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: EyepetizerFlutterItemLayout(title: '通知开关'),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: EyepetizerFlutterItemLayout(title: '我的徽章'),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: EyepetizerFlutterItemLayout(title: '客服咨询'),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: EyepetizerFlutterItemLayout(title: '我要投稿'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: EyepetizerFlutterItemLayout(
                        title: 'Version ${_version ?? 'Unknown'}',
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The source's avatar tap: signed out → login route, then reload; signed in
  /// → own person page.
  Future<void> _openProfile() async {
    final member = _login?.member;
    if (member == null) {
      await Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => const EyepetizerFlutterLoginPage(),
        ),
      );
      await loadUserData();
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EyepetizerFlutterPersonMainPage(
          uid: member.uid ?? 0,
          isMySelf: true,
        ),
      ),
    );
  }
}

/// The source's `收藏` / `缓存` columns: an icon over a label.
class _MineShortcut extends StatelessWidget {
  const _MineShortcut({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
