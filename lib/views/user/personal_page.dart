import 'package:dashboard/app/app_theme.dart';
import 'package:dashboard/app/user_info.dart';
import 'package:dashboard/app/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({Key? key}) : super(key: key);

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Provider.of<AppUserInfo>(context, listen: false).isLogin
          //     ? InkWell(
          //         onTap: () => Navigator.pushNamed(context, "/User"),
          //         child: UserAccountsDrawerHeader(
          //           currentAccountPicture: CircleAvatar(
          //             backgroundImage: NetworkImage(
          //               Provider.of<AppUserInfo>(context).loginInfo.photo,
          //               headers: {"Referer": "http://www.dmzj.com/"},
          //             ),
          //           ),
          //           accountName: InkWell(
          //             child: Text(
          //               Provider.of<AppUserInfo>(context).loginInfo.nickname,
          //               style: TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //           ),
          //           accountEmail: Text(Provider.of<AppUserInfo>(context)
          //                   .userProfile
          //                   ?.description ??
          //               ""),
          //           // decoration: BoxDecoration(
          //           //     image: DecorationImage(
          //           //   image: AssetImage("assets/img_ucenter_def_bac.jpg"),
          //           //   fit: BoxFit.cover,
          //           //   //colorFilter: ColorFilter.mode(Theme.of(context).accentColor.withOpacity(0.4), BlendMode.colorBurn)
          //           // )),
          //         ),
          //       )
          //     : InkWell(
          //         onTap: () => Navigator.pushNamed(context, "/Login"),
          //         child: UserAccountsDrawerHeader(
          //           currentAccountPicture: CircleAvatar(
          //             child: Icon(Icons.account_circle),
          //           ),
          //           accountName: InkWell(
          //             child: Text(
          //               "点击登录",
          //               style: TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //           ),
          //           accountEmail: Text("登录后享受更多功能"),
          //         ),
          //       ),
          Stack(
            children: <Widget>[
              Image.asset(
                "assets/img_ucenter_def_bac.jpg",
                fit: BoxFit.cover,
                height: 240,
                width: MediaQuery.of(context).size.width,
              ),
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 240,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Theme.of(context).colorScheme.secondary.withOpacity(1),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Provider.of<AppUserInfo>(context).isLogin
                      ? InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("退出登录"),
                                content: const Text("确定要退出登录吗?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("取消"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("确定"),
                                    onPressed: () {
                                      Provider.of<AppUserInfo>(
                                        context,
                                        listen: false,
                                      ).logout();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundImage:
                                      Utils.createCachedImageProvider(
                                        Provider.of<AppUserInfo>(
                                          context,
                                        ).loginInfo!.photo!,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Provider.of<AppUserInfo>(
                                  context,
                                ).loginInfo!.nickname!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Provider.of<AppUserInfo>(
                                      context,
                                    ).userProfile?.description ??
                                    "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: () => Navigator.pushNamed(context, "/Login"),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: CircleAvatar(
                                  child: Icon(Icons.account_circle),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "点击登录",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
          Material(
            color: Theme.of(context).cardColor,
            child: Column(
              children: <Widget>[
                // ListTile(
                //   title: Text("消息中心"),
                //   leading: Icon(Icons.email),
                //   trailing: Icon(Icons.chevron_right, color: Colors.grey),
                //   onTap: () => {},
                // ),
                ListTile(
                  title: const Text("我的订阅"),
                  leading: const Icon(Icons.favorite),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => Utils.openSubscribePage(context),
                ),
                ListTile(
                  title: const Text("浏览记录"),
                  leading: const Icon(Icons.history),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => Utils.openHistoryPage(context),
                ),
                ListTile(
                  title: const Text("我的评论"),
                  leading: const Icon(Icons.comment),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => Utils.openMyCommentPage(context),
                ),
                ListTile(
                  title: const Text("我的下载"),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  leading: const Icon(Icons.file_download),
                  onTap: () => {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Material(
            color: Theme.of(context).cardColor,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text("夜间模式"),
                  leading: const Icon(Icons.brightness_4),
                  trailing: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      Provider.of<AppTheme>(context).themeModeName,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  onTap: () => Provider.of<AppTheme>(
                    context,
                    listen: false,
                  ).showThemeModeDialog(context),
                ),
                ListTile(
                  title: const Text("设置"),
                  leading: const Icon(Icons.settings),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.pushNamed(context, "/Setting");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
