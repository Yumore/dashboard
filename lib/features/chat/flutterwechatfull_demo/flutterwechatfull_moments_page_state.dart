import 'package:flutter/material.dart';

import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_remote_image.dart';
import 'flutterwechatfull_style.dart';

import 'flutterwechatfull_moments_page.dart';

class FlutterWechatFullMomentsPageState
    extends State<FlutterWechatFullMomentsPage> {
  final ScrollController _controller = ScrollController();

  bool _appBarSolid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool solid = _controller.offset > 60.0;
    if (solid != _appBarSolid) {
      setState(() => _appBarSolid = solid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller: _controller,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: FlutterWechatFullLocalImage(
                          path: FlutterWechatFullImages.momentsCover,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        left: 0.0,
                        right: 0.0,
                        bottom: 0.0,
                        child: _buildMessageTip(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: _buildAppBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTip() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 9.0, 16.0, 9.0),
      child: Row(
        children: <Widget>[
          FlutterWechatFullRemoteImage(
            url: FlutterWechatFullDemoData.profileAvatarUrl,
            width: 30.0,
            height: 30.0,
            borderRadius: BorderRadius.circular(4.0),
          ),
          const SizedBox(width: 10.0),
          const Expanded(
            child: Text(
              '10条新消息',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0, color: Color(0xFF333333)),
            ),
          ),
          FlutterWechatFullLocalImage(
            path: FlutterWechatFullImages.momentsTipArrow,
            width: 15.0,
            height: 15.0,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final Color foreground = _appBarSolid
        ? const Color(0xFF181818)
        : Colors.white;
    return Container(
      color: _appBarSolid
          ? FlutterWechatFullStyle.background
          : Colors.transparent,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios, size: 18.0, color: foreground),
          ),
          Expanded(
            child: Text(
              _appBarSolid ? '朋友圈' : '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: FlutterWechatFullLocalImage(
              path: _appBarSolid
                  ? FlutterWechatFullImages.cameraOutlined
                  : FlutterWechatFullImages.cameraFilled,
              width: 24.0,
              height: 24.0,
            ),
          ),
        ],
      ),
    );
  }
}
