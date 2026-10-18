import 'package:dashboard/features/shared/ui/content_section_header.dart';
import 'package:dashboard/features/shared/ui/content_entry_section_view.dart';
import 'package:dashboard/features/live/live_channel.dart';
import 'package:dashboard/features/live/live_entry_catalog.dart';
import 'package:dashboard/features/live/live_hub_controller.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:dashboard/features/shared/ui/content_navigation.dart';
import 'package:dashboard/features/shared/ui/content_row.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Live module body: streaming-site entries first, then the subscription
/// playlist and its grouped channels.
class LiveHubBody extends StatelessWidget {
  const LiveHubBody({required this.controller, required this.input, super.key});

  final LiveHubController controller;
  final TextEditingController input;

  void _play(BuildContext context, LiveChannel channel) {
    openContentPage<void>(
      context,
      (_) => MediaPlaybackPage(
        title: channel.name,
        sources: [
          for (var i = 0; i < channel.urls.length; i++)
            MediaStreamSource(label: '线路 ${i + 1}', url: channel.urls[i]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final channels = controller.channels;
        final groups = <String, List<LiveChannel>>{};
        for (final channel in channels) {
          groups.putIfAbsent(channel.group, () => []).add(channel);
        }
        return ListView(
          padding: ModulePageScaffold.pagePadding,
          children: [
            for (var index = 0; index < liveEntryCatalog.length; index++) ...[
              if (index > 0) const SizedBox(height: ContentSpacing.md),
              ContentEntrySectionView(section: liveEntryCatalog[index]),
            ],
            const SizedBox(height: ContentSpacing.lg),
            const ContentSectionHeader(
              title: '订阅频道',
              description: '输入您有权使用的直播订阅地址，按分组选择频道',
            ),
            TextField(
              controller: input,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'M3U / TXT 订阅地址',
                hintText: 'https://example.com/playlist.m3u',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => controller.load(input.text),
            ),
            const SizedBox(height: ContentSpacing.md),
            FilledButton.icon(
              onPressed: controller.loading
                  ? null
                  : () => controller.load(input.text),
              icon: const Icon(Icons.refresh),
              label: Text(controller.loading ? '加载中…' : '加载频道'),
            ),
            if (controller.error != null)
              Padding(
                padding: const EdgeInsets.only(top: ContentSpacing.md),
                child: Text(
                  controller.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            if (!controller.loading && channels.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: ContentSpacing.xl),
                child: Text('输入您有权使用的直播订阅地址，加载后可按分组选择频道。'),
              ),
            for (final entry in groups.entries) ...[
              const SizedBox(height: ContentSpacing.lg),
              Text(entry.key, style: theme.textTheme.titleMedium),
              for (final channel in entry.value)
                ContentRow(
                  leadingIcon: Icons.live_tv_outlined,
                  title: channel.name,
                  subtitle: '${channel.urls.length} 条播放线路',
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _play(context, channel),
                ),
            ],
          ],
        );
      },
    );
  }
}
