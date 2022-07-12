import 'package:dashboard/app/config_helper.dart';
import 'package:flutter/material.dart';

class AppSetting with ChangeNotifier {
  AppSetting() {
    changeComicWebApi(ConfigHelper.getComicWebApi());
    changeComicVertical(ConfigHelper.getComicVertical());
    changeComicWakelock(ConfigHelper.getComicWakelock());
    changeReadReverse(ConfigHelper.getComicReadReverse());
    changeComicReadShowState(ConfigHelper.getComicReadShowState());
    changeComicReadShowStatusBar(ConfigHelper.getComicShowStatusBar());
    changeBrightness(ConfigHelper.getComicBrightness());
    changeComicSystemBrightness(ConfigHelper.getComicSystemBrightness());
    changeNovelFontSize(ConfigHelper.getNovelFontSize());
    changeNovelLineHeight(ConfigHelper.getNovelLineHeight());
    changeNovelReadDirection(ConfigHelper.getNovelReadDirection());
    changeNovelReadTheme(ConfigHelper.getNovelTheme());
  }

  bool _comicVerticalMode = false;

  get comicVerticalMode => _comicVerticalMode;

  void changeComicVertical(bool value) {
    _comicVerticalMode = value;

    notifyListeners();
    ConfigHelper.setComicVertical(value);
    if (value) {
      changeReadReverse(false);
    }
  }

  bool _comicWebApi = false;

  get comicWebApi => _comicWebApi;

  void changeComicWebApi(bool value) {
    _comicWebApi = value;
    notifyListeners();
    ConfigHelper.setComicWebApi(value);
  }

  bool _comicWakelock = false;

  get comicWakelock => _comicWakelock;

  void changeComicWakelock(bool value) {
    _comicWakelock = value;
    notifyListeners();
    ConfigHelper.setComicWakelock(value);
  }

  bool _comicReadReverse = false;

  get comicReadReverse => _comicReadReverse;

  void changeReadReverse(bool value) {
    _comicReadReverse = value;
    notifyListeners();
    ConfigHelper.setComicReadReverse(value);
    if (value) {
      changeComicVertical(false);
    }
  }

  bool _comicReadShowstate = false;

  get comicReadShowstate => _comicReadShowstate;

  void changeComicReadShowState(bool value) {
    _comicReadShowstate = value;
    notifyListeners();
    ConfigHelper.setComicReadShowState(value);
  }

  bool _comicReadShowStatusBar = false;

  get comicReadShowStatusBar => _comicReadShowStatusBar;

  void changeComicReadShowStatusBar(bool value) {
    _comicReadShowStatusBar = value;
    notifyListeners();
    ConfigHelper.setComicShowStatusBar(value);
  }

  bool _comicSystemBrightness = false;

  get comicSystemBrightness => _comicSystemBrightness;

  void changeComicSystemBrightness(bool value) {
    _comicSystemBrightness = value;
    notifyListeners();
    ConfigHelper.setComicSystemBrightness(value);
  }

  double _comicBrightness = 0;

  get comicBrightness => _comicBrightness;

  void changeBrightness(double value) {
    _comicBrightness = value;
    notifyListeners();
    ConfigHelper.setComicBrightness(value);
  }

  double _novelFontSize = 0;

  double get novelFontSize => _novelFontSize;

  void changeNovelFontSize(double value) {
    _novelFontSize = value;
    notifyListeners();
    ConfigHelper.setNovelFontSize(value);
  }

  double _novelLineHeight = 0;

  double get novelLineHeight => _novelLineHeight;

  void changeNovelLineHeight(double value) {
    _novelLineHeight = value;
    notifyListeners();
    ConfigHelper.setNovelLineHeight(value);
  }

  int _novelReadDirection = 0;

  get novelReadDirection => _novelReadDirection;

  void changeNovelReadDirection(int value) {
    _novelReadDirection = value;
    notifyListeners();
    ConfigHelper.setNovelReadDirection(value);
  }

  static List<Color> bgColors = [Color.fromRGBO(245, 239, 217, 1), Color.fromRGBO(248, 247, 252, 1), Color.fromRGBO(192, 237, 198, 1), Colors.black];
  static List<Color> fontColors = [
    Colors.black,
    Colors.black,
    Colors.black,
    Color.fromRGBO(200, 200, 200, 1),
  ];

  int _novelReadTheme = 0;

  get novelReadTheme => _novelReadTheme;

  void changeNovelReadTheme(int value) {
    _novelReadTheme = value;
    notifyListeners();
    ConfigHelper.setNovelTheme(value);
  }
}
