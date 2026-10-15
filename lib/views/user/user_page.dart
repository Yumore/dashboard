import 'package:dashboard/app/user_info.dart';
import 'package:dashboard/app/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            SizedBox(
              height: 36,
              width: 36,
              child: CircleAvatar(
                backgroundImage: Utils.createCachedImageProvider(
                  Provider.of<AppUserInfo>(context).userProfile!.cover!,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(Provider.of<AppUserInfo>(context).loginInfo!.nickname!),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("退出登录"),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () {
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
                        Provider.of<AppUserInfo>(context).logout();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Text(Provider.of<AppUserInfo>(context).loginInfo?.nickname ?? ""),
    );
  }
}
