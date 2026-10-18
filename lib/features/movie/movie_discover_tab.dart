import 'package:dashboard/features/shared/ui/async_content_view.dart';
import 'package:dashboard/features/shared/ui/content_cover.dart';
import 'package:dashboard/features/movie/movie_detail_launcher.dart';
import 'package:dashboard/features/movie/movie_hub_controller.dart';
import 'package:dashboard/features/movie/movie_item.dart';
import 'package:dashboard/features/shared/ui/content_row.dart';
import 'package:dashboard/features/shared/ui/content_status.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Movie "发现" tab: backend endpoint, classification and search results.
class MovieDiscoverTab extends StatelessWidget {
  const MovieDiscoverTab({required this.controller, super.key});

  final MovieHubController controller;

  Future<void> _connect(BuildContext context) async {
    final error = await controller.connect();
    if (error == null || !context.mounted) return;
    showContentError(context, error);
  }

  Widget _list(BuildContext context, List<MovieItem> items) {
    return ListView.builder(
      padding: ModulePageScaffold.pagePadding,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ContentRow(
          leading: ContentCover(url: item.poster),
          title: item.title,
          subtitle: item.category,
          onTap: () => openMovieDetail(context, item, controller),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final source = controller.results;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(ContentSpacing.md),
              child: TextField(
                controller: controller.endpointInput,
                decoration: InputDecoration(
                  labelText: '影视服务地址',
                  hintText: 'https://your-server.example',
                  suffixIcon: IconButton(
                    onPressed: () => _connect(context),
                    icon: const Icon(Icons.link),
                  ),
                ),
                onSubmitted: (_) => _connect(context),
              ),
            ),
            if (controller.connected)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ContentSpacing.md,
                ),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: controller.classify,
                      items: ['电影', '电视剧', '动漫', '综艺']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        controller.classifyAs(value);
                      },
                    ),
                    const SizedBox(width: ContentSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: controller.searchInput,
                        decoration: InputDecoration(
                          labelText: '搜索影片',
                          suffixIcon: IconButton(
                            onPressed: controller.search,
                            icon: const Icon(Icons.search),
                          ),
                        ),
                        onSubmitted: (_) => controller.search(),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: AsyncContentView<List<MovieItem>>(
                future: source,
                idleMessage: '原影视工程依赖专用后端，请填写可访问的服务地址。',
                emptyMessage: '暂无影视内容',
                onRetry: () => _connect(context),
                isEmpty: (items) => items.isEmpty,
                builder: _list,
              ),
            ),
          ],
        );
      },
    );
  }
}
