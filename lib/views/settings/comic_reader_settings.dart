import 'package:dashboard/app/app_setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComicReaderSettings extends StatefulWidget {
  ComicReaderSettings({Key? key}) : super(key: key);

  @override
  _ComicReaderSettingsState createState() => _ComicReaderSettingsState();
}

class _ComicReaderSettingsState extends State<ComicReaderSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('漫画阅读设置'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
              title: Text(
                "使用系统亮度",
              ),
              value: Provider.of<AppSetting>(context).comicSystemBrightness,
              onChanged: (e) {
                Provider.of<AppSetting>(context, listen: false).changeComicSystemBrightness(e);
              }),
          !Provider.of<AppSetting>(context).comicSystemBrightness
              ? Row(
            children: <Widget>[
              SizedBox(width: 12),
              Icon(
                Icons.brightness_2,
                size: 18,
              ),
              Expanded(
                  child: Slider(
                      value: Provider.of<AppSetting>(context).comicBrightness,
                      max: 1,
                      min: 0.01,
                      onChanged: (e) {
                        Provider.of<AppSetting>(context, listen: false).changeBrightness(e);
                      })),
              Icon(Icons.brightness_5, size: 18),
              SizedBox(width: 12),
            ],
          )
              : Container(),
          SwitchListTile(
              title: Text(
                "使用网页API",
              ),
              subtitle: Text(
                "网页API部分单行本不分页",
                style: TextStyle(color: Colors.grey),
              ),
              value: Provider.of<AppSetting>(context).comicWebApi,
              onChanged: (e) {
                Provider.of<AppSetting>(context, listen: false).changeComicWebApi(e);
              }),
          SwitchListTile(
              title: Text(
                "竖向阅读",
              ),
              value: Provider.of<AppSetting>(context).comicVerticalMode,
              onChanged: (e) {
                Provider.of<AppSetting>(context, listen: false).changeComicVertical(e);
                //Navigator.pop(context);
              }),
          !Provider.of<AppSetting>(context).comicVerticalMode
              ? SwitchListTile(
              title: Text(
                "日漫模式",
              ),
              value: Provider.of<AppSetting>(context).comicReadReverse,
              onChanged: (e) {
                Provider.of<AppSetting>(context, listen: false).changeReadReverse(e);
              })
              : Container(),
          SwitchListTile(
              title: Text(
                "屏幕常亮",
              ),
              value: Provider.of<AppSetting>(context).comicWakelock,
              onChanged: (e) {
                Provider.of<AppSetting>(context, listen: false).changeComicWakelock(e);
              }),
          SwitchListTile(
              title: Text(
                "全屏阅读",
              ),
              value: Provider.of<AppSetting>(context).comicReadShowStatusBar,
              onChanged: (e) {
                Provider.of<AppSetting>(context, listen: false).changeComicReadShowStatusBar(e);
              }),
          SwitchListTile(
              title: Text(
                "显示状态信息",
              ),
              value: Provider.of<AppSetting>(context).comicReadShowstate,
              onChanged: (e) {
                Provider.of<AppSetting>(context, listen: false).changeComicReadShowState(e);
              }),
          // SwitchListTile(
          //     title: Text(
          //       "音量键翻页",
          //
          //     ),
          //     value: false,
          //     onChanged: (e) => {})
        ],
      ),
    );
  }
}
