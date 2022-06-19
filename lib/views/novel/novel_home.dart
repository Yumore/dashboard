import 'package:flutter/material.dart';
import 'package:flutter_dmzj/app/utils.dart';
import 'package:flutter_dmzj/views/novel/novel_category.dart';
import 'package:flutter_dmzj/views/novel/novel_rank.dart';
import 'package:flutter_dmzj/views/novel/novel_recommend.dart';
import 'package:flutter_dmzj/views/novel/novel_search.dart';
import 'package:flutter_dmzj/views/novel/novel_update.dart';

class NovelHomePage extends StatefulWidget {
  @override
  _NovelHomePageState createState() => _NovelHomePageState();
}

class _NovelHomePageState extends State<NovelHomePage> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Utils.changeNovelHomeTabIndex.on<int>().listen((e) {
      _tabController!.animateTo(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TabBar(
            controller: _tabController,
            tabs: <Widget>[Tab(child: Text("推荐")), Tab(child: Text("更新")), Tab(child: Text("分类")), Tab(child: Text("排行"))],
            indicatorSize: TabBarIndicatorSize.label,
            //labelPadding: EdgeInsets.all(8),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              tooltip: "搜索",
              onPressed: () {
                showSearch(context: context, delegate: NovelSearchBarDelegate());
              },
            )
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            NovelRecommend(),
            NovelUpdatePage(),
            NovelCategoryPage(),
            NovelRankPage(),
          ],
        ));
  }
}
