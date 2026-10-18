import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_attention_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_recommend_page.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterCommunityPage].
class EyepetizerFlutterCommunityPageState
    extends State<EyepetizerFlutterCommunityPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const List<String> tabTitles = <String>['推荐', '关注'];

  late final TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TabBar(
        tabs: tabTitles
            .map((title) => Tab(text: title))
            .toList(growable: false),
        controller: _tabController,
        labelColor: Colors.blueAccent,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blueAccent,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          EyepetizerFlutterCommunityRecommendPage(),
          EyepetizerFlutterAttentionPage(),
        ],
      ),
    );
  }
}
