import 'dart:async';
import 'flutterwechatfull_demo_page.dart';

import 'package:flutter/material.dart';

import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_login_page.dart';
import 'flutterwechatfull_local_image.dart';

/// Splash ad screen from the source `lib/views/splash/splash_page.dart`.
///
/// The source shows four full-screen ads with a five second "跳过" countdown
/// before routing to the login page; the ad images, the auto-advance interval
/// and the countdown length are copied from the source.
class FlutterWechatFullDemoPageState extends State<FlutterWechatFullDemoPage> {
  static const int _countdownSeconds = 5;

  final PageController _pageController = PageController();

  Timer? _countdownTimer;
  Timer? _carouselTimer;
  int _secondsLeft = _countdownSeconds;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }
      setState(() {
        _secondsLeft--;
      });
      if (_secondsLeft <= 0) {
        timer.cancel();
        _openLogin();
      }
    });
    _carouselTimer = Timer.periodic(const Duration(milliseconds: 1500), (
      timer,
    ) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      _page = (_page + 1) % FlutterWechatFullImages.adSkins.length;
      _pageController.animateToPage(
        _page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openLogin() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const FlutterWechatFullLoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000A18),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: FlutterWechatFullImages.adSkins.length,
              onPageChanged: (index) => _page = index,
              itemBuilder: (context, index) => FlutterWechatFullLocalImage(
                path: FlutterWechatFullImages.adSkins[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 15.0,
            right: 16.0,
            child: GestureDetector(
              onTap: _openLogin,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  border: Border.all(color: Colors.white30, width: 0.5),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '跳过 $_secondsLeft',
                  style: const TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
