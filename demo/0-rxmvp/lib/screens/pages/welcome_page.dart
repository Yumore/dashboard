import 'package:admin/constants/app_colors.dart';
import 'package:admin/http/api_manager.dart';
import 'package:admin/screens/pages/home_page.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await ApiManager.instance.initClient();

      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        color: AppColors.colorPrimary,
        child: Image.asset(
          "assets/images/ic_logo.png",
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
        ));
  }
}
