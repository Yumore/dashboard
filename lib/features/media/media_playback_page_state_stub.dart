import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:flutter/material.dart';

/// Web 平台没有 media_kit 原生播放库时的降级播放页。
///
/// 保留页面外壳与播放源信息，明确提示需要移动端/桌面端才能播放，
/// 不伪装成"正在播放"。
class MediaPlaybackPageState extends State<MediaPlaybackPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tv_off_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('当前平台暂不支持内嵌播放', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Web 构建不包含 media_kit 原生播放库。请使用 Android/iOS/macOS/Windows/Linux 客户端播放。',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  for (final source in widget.sources)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${source.label} · ${source.url}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
