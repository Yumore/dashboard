import 'package:dashboard/features/reading/flutterebook/data/feedbooks_dio.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_home_repository.dart';
import 'package:dashboard/features/reading/flutterebook/feedbooks_api.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/models/link.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_home_feed_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/book_details/feedbooks_book_details_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/genre/feedbooks_genre_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/home/feedbooks_home_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_error_widget.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_featured_section.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_genre_row.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_loading_widget.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_new_section.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_section_title.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// [FeedbooksHomePage] 的状态。
///
/// 源工程逻辑：initState 后在 post-frame 拉 two-feed 数据；加载中显示
/// [FeedbooksLoadingWidget]；出错显示 [FeedbooksErrorWidget]（重试 = 重新
/// `fetch()`）；成功后是 200 高的精选横排 + 分类胶囊 + 最新入库列表，
/// 整页可下拉刷新。
class FeedbooksHomePageState extends State<FeedbooksHomePage> {
  Dio? _ownedDio;
  FeedbooksHomeRepository? _ownedRepository;
  FeedbooksHomeFeedController? _ownedController;

  Dio get _dio => widget.dio ?? (_ownedDio ??= createFeedbooksDio());

  FeedbooksHomeRepository get _repository =>
      _ownedRepository ??= FeedbooksHomeRepository(_dio);

  FeedbooksHomeFeedController get _controller =>
      widget.controller ??
      (_ownedController ??= FeedbooksHomeFeedController(
        repository: _repository,
      ));

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.fetch();
  }

  @override
  void dispose() {
    _ownedController?.removeListener(_onControllerChanged);
    _ownedController?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openBook(FeedbooksEntry entry, FeedbooksBookHeroTags tags) {
    Navigator.of(context).push(
      FeedbooksBookDetailsPage.route(entry: entry, tags: tags, dio: _dio),
    );
  }

  void _openGenre(FeedbooksLink link) {
    Navigator.of(context).push(
      FeedbooksGenrePage.route(
        title: '${link.title}',
        url: link.href!,
        dio: _dio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          FeedbooksApi.appName,
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_controller.error != null) {
      return FeedbooksErrorWidget(refreshCallBack: _controller.fetch);
    }
    final FeedbooksHomeFeedData? feeds = _controller.data;
    if (feeds == null) {
      return const FeedbooksLoadingWidget();
    }
    return RefreshIndicator(
      onRefresh: () async => _controller.fetch(),
      child: ListView(
        children: <Widget>[
          FeedbooksFeaturedSection(
            popular: feeds.popularFeed,
            onTapBook: _openBook,
          ),
          const SizedBox(height: 20.0),
          const FeedbooksSectionTitle(title: 'Categories'),
          const SizedBox(height: 10.0),
          FeedbooksGenreRow(popular: feeds.popularFeed, onTapLink: _openGenre),
          const SizedBox(height: 20.0),
          const FeedbooksSectionTitle(title: 'Recently Added'),
          const SizedBox(height: 20.0),
          FeedbooksNewSection(recent: feeds.recentFeed, onTapBook: _openBook),
        ],
      ),
    );
  }
}
