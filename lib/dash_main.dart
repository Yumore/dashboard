import 'package:admin/constants.dart';
import 'package:admin/controllers/MenuController.dart';
import 'package:admin/routers.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main2() {
  runApp(AppMain());

  // final navigatorKey = GlobalKey<NavigatorState>();
  //
  // runApp(MaterialApp(
  //   navigatorKey: navigatorKey,
  //   theme: ThemeData(
  //       primaryColor: AppColors.colorPrimary,
  //       accentColor: AppColors.colorPrimary),
  //   home: WelcomePage(),
  // ));
}

class AppMain extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admin Dashboard',

      /// 注册全局的静态路由
      routes: staticRouters,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuController(),
          ),
        ],
        child: MainScreen(),
      ),
    );
  }
}
