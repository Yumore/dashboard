import 'package:admin/app/root_scene.dart';
import 'package:admin/app/sq_color.dart';
import 'package:flutter/material.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class AppScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '书旗小说',
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        dividerColor: Color(0xffeeeeee),
        scaffoldBackgroundColor: SQColor.paper,
        textTheme: TextTheme(bodyText1: TextStyle(color: SQColor.darkGray)),
      ),
      home: RootScene(),
    );
  }
}
