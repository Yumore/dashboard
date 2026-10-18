import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_category.dart';
import 'package:dashboard/features/comic/hakacomic/haka_home_controller.dart';
import 'package:dashboard/features/comic/hakacomic/haka_home_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_network_cover.dart';
import 'package:dashboard/features/comic/hakacomic/haka_state_view.dart';

/// State of [HakaHomePage]; loads the categories once from `initState`.
class HakaHomePageState extends State<HakaHomePage> {
  late final HakaHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HakaHomeController(repository: widget.repository)..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return HakaStateView<List<HakaCategory>>(
          state: _controller.state,
          onRetry: () => _controller.load(),
          emptyMessage: '暂无分类',
          builder: (context, categories) {
            return RefreshIndicator(
              onRefresh: _controller.refresh,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return InkWell(
                    onTap: () => widget.onOpenCategory(category),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: HakaNetworkCover(
                            image: category.thumb,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (category.description.isNotEmpty)
                          Text(
                            category.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
