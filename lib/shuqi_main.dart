import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app_scene.dart';

void main1() {
  runApp(AppScene());

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
