import 'package:dashboard/features/crawler/crawl_task_page.dart';
import 'package:dashboard/features/crawler/crawler_hub_controller.dart';
import 'package:dashboard/features/shared/ui/content_navigation.dart';
import 'package:dashboard/features/shared/ui/content_row.dart';
import 'package:dashboard/features/shared/ui/content_status.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Crawler module body: the configured sources and their task state.
class CrawlerHubBody extends StatelessWidget {
  const CrawlerHubBody({required this.controller, super.key});

  final CrawlerHubController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final error = controller.error;
        if (error != null) {
          return ContentStatusView(
            message: '读取任务配置失败：$error',
            icon: Icons.error_outline,
          );
        }
        return ListView(
          padding: ModulePageScaffold.pagePadding,
          children: [
            const Padding(
              padding: EdgeInsets.all(ContentSpacing.sm),
              child: Text(
                '仅采集您有权访问的网页。每次手动运行请求一个页面，不自动遍历、登录或绕过访问限制。退出本模块会取消任务。',
              ),
            ),
            for (final task in controller.tasks)
              AnimatedBuilder(
                animation: task,
                builder: (context, _) => ContentRow(
                  title: task.config.name,
                  subtitle:
                      '${task.state.label} · ${task.items.length} 条结果 · ${task.logs.length} 条日志',
                  onTap: () => openContentPage<void>(
                    context,
                    (_) => CrawlTaskPage(task: task, store: controller.store),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
