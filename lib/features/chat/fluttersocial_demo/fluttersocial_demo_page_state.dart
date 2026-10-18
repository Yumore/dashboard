import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_available_images.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_demo_config.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_demo_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_login_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_palette.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_photo.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_register_page.dart';
import 'package:flutter/material.dart';

/// Port of the source landing screen (source `lib/views/landing.dart`).
///
/// The source's `SystemChrome.setSystemUIOverlayStyle` call is dropped: it only
/// affects a mobile status bar and has no meaning in the host.
class FlutterSocialDemoPageState extends State<FlutterSocialDemoPage> {
  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final logo = const FlutterSocialPhoto(
      source: FlutterSocialAvailableImages.appLogo,
      width: 100.0,
      height: 100.0,
      borderRadius: BorderRadius.zero,
      icon: Icons.favorite_border,
    );

    final appName = Column(
      children: <Widget>[
        const Text(
          FlutterSocialDemoConfig.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
        Text(
          FlutterSocialDemoConfig.appTagline,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final loginBtn = InkWell(
      onTap: () => _open(const FlutterSocialLoginPage()),
      child: Container(
        height: 60.0,
        width: size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(color: Colors.white),
          color: Colors.transparent,
        ),
        child: const Center(
          child: Text(
            'LOG IN',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    final registerBtn = SizedBox(
      height: 60.0,
      width: size.width,
      child: ElevatedButton(
        onPressed: () => _open(const FlutterSocialRegisterPage()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
        child: const Text(
          'SIGN UP',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),
        ),
      ),
    );

    final buttons = Padding(
      padding: const EdgeInsets.only(
        top: 80.0,
        bottom: 30.0,
        left: 30.0,
        right: 30.0,
      ),
      child: Column(
        children: <Widget>[loginBtn, const SizedBox(height: 20.0), registerBtn],
      ),
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 70.0),
            constraints: BoxConstraints(minHeight: size.height),
            width: size.width,
            decoration: const BoxDecoration(
              gradient: FlutterSocialPalette.primaryGradient,
            ),
            child: Column(children: <Widget>[logo, appName, buttons]),
          ),
          Positioned(
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: FlutterSocialPhoto(
                source: FlutterSocialAvailableImages.homePage,
                width: size.width,
                height: 300.0,
                borderRadius: BorderRadius.zero,
                icon: Icons.photo_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
