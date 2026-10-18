import 'dart:async';

import 'package:dashboard/features/reading/flutterebook/data/feedbooks_dio.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_explore_repository.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_genre_feed_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/book_details/feedbooks_book_details_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/genre/feedbooks_genre_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_list_item.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_error_widget.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// [FeedbooksGenrePage] 的状态。
///
/// 分页规则照抄源工程：`page` 从 1 开始，滚动位置**恰好等于** maxScrollExtent
/// 且不在加载中时 `page += 1`，然后用 `'$_url&page=$page'` 拉下一页并
/// **追加**到已有列表（源工程的 url 本身已带 `?`，所以直接拼 `&page=`）。
class FeedbooksGenrePageState extends State<FeedbooksGenrePage> {
  final ScrollController _scrollController = ScrollController();

  Dio? _ownedDio;
  FeedbooksExploreRepository? _ownedRepository;
  FeedbooksGenreFeedController? _ownedController;

  int _page = 1;

  Dio get _dio => widget.dio ?? (_ownedDio ??= createFeedbooksDio());

  FeedbooksExploreRepository get _repository =>
      _ownedRepository ??= FeedbooksExploreRepository(_dio);

  FeedbooksGenreFeedController get _controller =>
      widget.controller ??
      (_ownedController ??= FeedbooksGenreFeedController(
        repository: _repository,
        url: widget.url,
      ));

  @override
  void initState() {
    super.initState();
    _bindController();
    _scrollController.addListener(_paginationListener);
    _controller.fetch();
  }

  @override
  void didUpdateWidget(covariant FeedbooksGenrePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.controller != widget.controller) {
      if (widget.controller == null) {
        _ownedController?.removeListener(_onControllerChanged);
        _ownedController?.dispose();
        _ownedController = null;
      }
      _page = 1;
      _bindController();
      _controller.fetch();
    }
  }

  @override
  void dispose() {
    _ownedController?.removeListener(_onControllerChanged);
    _ownedController?.dispose();
    _scrollController.removeListener(_paginationListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _bindController() {
    // removeListener 对未注册的回调是空操作，避免重复绑定。
    _controller.removeListener(_onControllerChanged);
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _paginationListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels !=
        _scrollController.position.maxScrollExtent) {
      return;
    }
    final FeedbooksGenreFeedData? data = _controller.data;
    if (data == null || data.loadingMore) return;
    _page += 1;
    _controller.paginate(_page);
    Timer(const Duration(milliseconds: 100), () {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn,
      );
    });
  }

  void _openBook(FeedbooksEntry entry, FeedbooksBookHeroTags tags) {
    Navigator.of(context).push(
      FeedbooksBookDetailsPage.route(entry: entry, tags: tags, dio: _dio),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(widget.title)),
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
    final FeedbooksGenreFeedData? data = _controller.data;
    if (data == null) {
      return const FeedbooksLoadingWidget();
    }
    final List<FeedbooksEntry> books = data.books;
    return ListView(
      controller: _scrollController,
      children: <Widget>[
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          itemCount: books.length,
          itemBuilder: (BuildContext context, int index) {
            final FeedbooksEntry entry = books[index];
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: FeedbooksBookListItem(
                entry: entry,
                onTap: (FeedbooksBookHeroTags tags) => _openBook(entry, tags),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        if (data.loadingMore)
          const SizedBox(height: 80, child: FeedbooksLoadingWidget()),
      ],
    );
  }
}
