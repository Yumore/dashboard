import 'package:dashboard/features/movie/dytt/dytt_category.dart';
import 'package:dashboard/features/movie/dytt/dytt_detail_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_list_controller.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_detail.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_tile.dart';
import 'package:dashboard/features/movie/dytt/dytt_search_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_signing_notice.dart';
import 'package:flutter/material.dart';

/// 搜索页状态：提交时才创建控制器并发请求，未提交不发请求。
///
/// 搜索结果复用 `DyttListController`（同一接口、同一分页规则），
/// 分类默认为「最新电影」，与首页第一个标签一致。
class DyttSearchPageState extends State<DyttSearchPage> {
  late final TextEditingController _input;
  DyttCategory _category = DyttCategory.latest;
  DyttListController? _controller;

  @override
  void initState() {
    super.initState();
    _input = TextEditingController();
  }

  @override
  void dispose() {
    _controller
      ?..removeListener(_onChanged)
      ..dispose();
    _input.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _search() {
    final query = _input.text.trim();
    if (query.isEmpty || !widget.api.signingSupported) return;
    _controller
      ?..removeListener(_onChanged)
      ..dispose();
    final controller = DyttListController(
      api: widget.api,
      categoryId: _category.categoryId,
      searchContent: query,
    )..addListener(_onChanged);
    setState(() => _controller = controller);
    controller.load();
  }

  void _open(DyttMovieDetail movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DyttDetailPage(api: widget.api, movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索电影天堂')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      labelText: '搜索影片',
                      hintText: '输入片名关键词',
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(
                  tooltip: '搜索',
                  icon: const Icon(Icons.search),
                  onPressed: widget.api.signingSupported ? _search : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('分类'),
                const SizedBox(width: 8),
                DropdownButton<DyttCategory>(
                  value: _category,
                  items: [
                    for (final category in DyttCategory.values)
                      DropdownMenuItem<DyttCategory>(
                        value: category,
                        child: Text(category.label),
                      ),
                  ],
                  onChanged: (category) {
                    if (category == null) return;
                    setState(() => _category = category);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.api.signingSupported
                ? _results()
                : ListView(
                    children: const [
                      DyttSigningNotice(),
                      SizedBox(height: 32),
                      Center(child: Text('签名不可用，未发起搜索')),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _results() {
    final controller = _controller;
    if (controller == null) {
      return const Center(child: Text('输入关键词后搜索'));
    }
    if (controller.isLoading && controller.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null && controller.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => controller.load(refresh: true),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    if (controller.items.isEmpty) {
      return const Center(child: Text('没有找到相关影片'));
    }
    final items = controller.items;
    final showFooter = controller.hasMore || controller.isLoadingMore;
    return ListView.separated(
      itemCount: items.length + (showFooter ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: controller.isLoadingMore
                  ? const CircularProgressIndicator()
                  : TextButton(
                      onPressed: controller.loadMore,
                      child: Text(controller.moreError ?? '加载更多'),
                    ),
            ),
          );
        }
        final movie = items[index];
        return DyttMovieTile(movie: movie, onTap: () => _open(movie));
      },
    );
  }
}
