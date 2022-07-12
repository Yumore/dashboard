import 'dart:io';

import 'package:dashboard/app/app_setting.dart';
import 'package:dashboard/app/config_helper.dart';
import 'package:dashboard/app/utils.dart';
import 'package:dashboard/sql/comic_down.dart';
import 'package:dashboard/sql/comic_history.dart';
import 'package:dashboard/views/comic/comic_home.dart';
import 'package:dashboard/views/news/news_home.dart';
import 'package:dashboard/views/novel/novel_home.dart';
import 'package:dashboard/views/setting_page.dart';
import 'package:dashboard/views/settings/comic_reader_settings.dart';
import 'package:dashboard/views/settings/novel_reader_settings.dart';
import 'package:dashboard/views/user/login_page.dart';
import 'package:dashboard/views/user/personal_page.dart';
import 'package:dashboard/views/user/user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app/app_theme.dart';
import 'app/user_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  ConfigHelper.prefs = await SharedPreferences.getInstance();
  await initDatabase();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppTheme>(create: (_) => AppTheme(), lazy: false),
      ChangeNotifierProvider<AppUserInfo>(create: (_) => AppUserInfo(), lazy: false),
      ChangeNotifierProvider<AppSetting>(create: (_) => AppSetting(), lazy: false),
    ],
    child: MyApp(),
  ));
}

Future initDatabase() async {
  var databasesPath = await getDatabasesPath();
  // File(databasesPath+"/nsplayer.db").deleteSync();
  var db = await openDatabase(databasesPath + "/comic_history.db", version: 1, onCreate: (Database _db, int version) async {
    await _db.execute('''
create table $comicHistoryTable ( 
  $comicHistoryColumnComicID integer primary key not null, 
  $comicHistoryColumnChapterID integer not null,
  $comicHistoryColumnPage double not null,
  $comicHistoryMode integer not null)
''');

    await _db.execute('''
create table $comicDownloadTableName (
$comicDownloadColumnChapterID integer primary key not null,
$comicDownloadColumnChapterName text not null,
$comicDownloadColumnComicID integer not null,
$comicDownloadColumnComicName text not null,
$comicDownloadColumnStatus integer not null,
$comicDownloadColumnVolume text not null,
$comicDownloadColumnPage integer ,
$comicDownloadColumnCount integer ,
$comicDownloadColumnSavePath text ,
$comicDownloadColumnUrls text )
''');
  });

  ComicHistoryProvider.database = db;
  ComicDownloadProvider.database = db;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '动漫之家Flutter',
      theme: ThemeData(
        primarySwatch: Provider.of<AppTheme>(context).themeColor,
        appBarTheme: const AppBarTheme(
          brightness: Brightness.dark,
        ),
      ),
      themeMode: Provider.of<AppTheme>(context).themeMode,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Provider.of<AppTheme>(context).themeColor,
        accentColor: Provider.of<AppTheme>(context).themeColor,
      ),
      home: MyHomePage(),
      initialRoute: "/",
      routes: {
        "/Setting": (_) => SettingPage(),
        "/Login": (_) => LoginPage(),
        "/User": (_) => UserPage(),
        "/ComicReaderSettings": (_) => ComicReaderSettings(),
        "/NovelReaderSettings": (_) => NovelReaderSettings(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  static NewsHomePage? newsPage;
  static NovelHomePage? novelPage;
  List<Widget> pages = [ComicHomePage(), Container(), Container(), PersonalPage()];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    checkUpdate();
  }

  void checkUpdate() async {
    var newVer = await Utils.checkVersion();
    if (newVer == null) {
      return;
    }
    if (await Utils.showAlertDialogAsync(context, const Text('有新版本可以更新'), Text(newVer.message!))) {
      if (Platform.isAndroid) {
        launch(newVer.android_url!);
      } else {
        launch(newVer.ios_url!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            if (index == 1 && newsPage == null) {
              newsPage = NewsHomePage();
              pages[1] = newsPage ?? NewsHomePage();
            }
            if (index == 2 && novelPage == null) {
              novelPage = NovelHomePage();
              pages[2] = novelPage ?? NovelHomePage();
            }
            _index = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: "漫画",
            icon: Icon(Icons.library_books),
          ),
          BottomNavigationBarItem(
            label: "新闻",
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            label: "轻小说",
            icon: Icon(Icons.book),
          ),
          BottomNavigationBarItem(
            label: "我的",
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          // NavigationRail(
          //   backgroundColor: Theme.of(context).bottomAppBarColor,
          //     onDestinationSelected: (int index) {
          //       setState(() {
          //         _index = index;
          //       });
          //     },
          //     labelType: NavigationRailLabelType.all,
          //     destinations: [
          //       NavigationRailDestination(
          //         icon: Icon(Icons.library_books),
          //         label: Text('漫画'),
          //       ),
          //       NavigationRailDestination(
          //         icon: Icon(Icons.whatshot),
          //         label: Text('新闻'),
          //       ),
          //       NavigationRailDestination(
          //         icon: Icon(Icons.book),
          //         label: Text('轻小说'),
          //       ),
          //       NavigationRailDestination(
          //         icon: Icon(Icons.account_circle),
          //         label: Text('我的'),
          //       ),
          //     ],
          //     selectedIndex: _index),
          // VerticalDivider(thickness: 1, width: 1),
          Expanded(
              child: IndexedStack(
            index: _index,
            children: pages,
          ))
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
