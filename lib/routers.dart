import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/wandroid/funny_screen.dart';

/// TODO 使用说明
/// 结束所有页面并返回
/// Navigator.of(context).pushNamedAndRemoveUntil( "/loginPage", ModalRoute.withName("/loginPage"));
/// -------------------------------
/// 跳转任意界面
/// Navigator.of(context).popUntil(ModalRoute.withName("/homePage"));
/// -------------------------------
/// Navigator.push( context, MaterialPageRoute(builder: (context) => YourWidget()),);
/// -------------------------------
/// Navigator.pushNamed(context, '/a_route_name');
/// MaterialPageRoute(
//   builder: (BuildContext context) {
//     return YourWidget();
//   },
//   settings: RouteSettings(arguments: your_param_object),
// );
/// --------------------------------
var staticRouters = {
  ROUTER_DASHBOARD: (context) => DashboardScreen(),
  ROUTER_FUNNY: (context) => FunnyScreen(),
};

/// TODO 路由常量
/// dashboard
const String ROUTER_DASHBOARD = "/dashboard";

/// 玩安卓页面
const String ROUTER_FUNNY = "funny";
