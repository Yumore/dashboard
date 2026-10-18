import 'package:dashboard/features/reading/flutterebook/data/feedbooks_dio.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_explore_repository.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_home_repository.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/models/link.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_genre_feed_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_home_feed_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/book_details/feedbooks_book_details_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/explore/feedbooks_explore_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/genre/feedbooks_genre_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_error_widget.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_loading_widget.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_section_book_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// [FeedbooksExplorePage] 的状态。
///
/// 源工程逻辑：popular feed 的 `link` 里 index < 10 的是 OPDS 导航（不是
/// 分类），直接跳过；其余每个 link 渲染一个
/// [FeedbooksSectionBookList]（标题 + `See All` + 该分类的横向书列），
/// 每个分区自己抓一次该分类 feed。
class FeedbooksExplorePageState extends State<FeedbooksExplorePage> {
  Dio? _ownedDio;
  FeedbooksHomeRepository? _ownedRepository;
  FeedbooksExploreRepository? _ownedExploreRepository;
  FeedbooksHomeFeedController? _ownedController;

  Dio get _dio => widget.dio ?? (_ownedDio ??= createFeedbooksDio());

  FeedbooksHomeRepository get _repository =>
      _ownedRepository ??= FeedbooksHomeRepository(_dio);

  FeedbooksExploreRepository get _exploreRepository =>
      _ownedExploreRepository ??= FeedbooksExploreRepository(_dio);

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

  FeedbooksGenreFeedController _genreController(String url) =>
      FeedbooksGenreFeedController(repository: _exploreRepository, url: url);

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
      appBar: AppBar(centerTitle: true, title: const Text('Explore')),
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
    final List<FeedbooksLink> links = feeds.popularFeed.feed?.link ?? const [];
    return ListView.builder(
      itemCount: links.length,
      itemBuilder: (BuildContext context, int index) {
        final FeedbooksLink link = links[index];

        // We don't need the tags from 0-9 because they are not categories.
        if (index < 10) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: FeedbooksSectionBookList(
            link: link,
            controllerFactory: _genreController,
            onTapBook: _openBook,
            onSeeAll: _openGenre,
          ),
        );
      },
    );
  }
}
