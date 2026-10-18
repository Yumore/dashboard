import 'package:dashboard/features/movie/youtubedl/youtubedl_bytes.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_status.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_task.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_progress.dart';
import 'package:flutter/material.dart';

/// One download row: progress bar, speed, ETA and state-appropriate controls.
class YoutubeDlDownloadTile extends StatelessWidget {
  const YoutubeDlDownloadTile({
    super.key,
    required this.task,
    required this.now,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onRemove,
  });

  final YoutubeDlDownloadTask task;

  /// Injected so tests can render deterministic speed/ETA values.
  final DateTime now;

  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final progress = task.progressAt(now);
    final status = task.status;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon(status), color: _color(context, status)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                if (status != YoutubeDlDownloadStatus.needsMuxer)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress.isIndeterminate
                          ? null
                          : progress.percent / 100,
                      minHeight: 5,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  _subtitle(progress),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          _actions(status),
        ],
      ),
    );
  }

  String _subtitle(YoutubeDlProgress progress) {
    final status = task.status;
    switch (status) {
      case YoutubeDlDownloadStatus.pending:
        return '${status.label} · ${YoutubeDlBytes.format(task.totalBytes)}';
      case YoutubeDlDownloadStatus.running:
        final total = task.totalBytes > 0
            ? YoutubeDlBytes.format(task.totalBytes)
            : '未知大小';
        return '${status.label} · ${progress.percent}% · '
            '${YoutubeDlBytes.format(task.downloadedBytes)} / $total · '
            '${progress.speedLabel} · 剩余 ${progress.etaLabel}';
      case YoutubeDlDownloadStatus.paused:
        return '${status.label} · ${progress.percent}% · '
            '${YoutubeDlBytes.format(task.downloadedBytes)} / '
            '${YoutubeDlBytes.format(task.totalBytes)}';
      case YoutubeDlDownloadStatus.done:
        return '${status.label} · ${YoutubeDlBytes.format(task.totalBytes)}';
      case YoutubeDlDownloadStatus.failed:
        return task.error.isEmpty
            ? status.label
            : '${status.label} · ${task.error}';
      case YoutubeDlDownloadStatus.cancelled:
        return status.label;
      case YoutubeDlDownloadStatus.needsMuxer:
        return task.error.isEmpty ? status.label : task.error;
    }
  }

  Widget _actions(YoutubeDlDownloadStatus status) {
    switch (status) {
      case YoutubeDlDownloadStatus.pending:
      case YoutubeDlDownloadStatus.running:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '暂停',
              onPressed: onPause,
              icon: const Icon(Icons.pause_circle_outline, size: 20),
            ),
            IconButton(
              tooltip: '取消',
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined, size: 20),
            ),
          ],
        );
      case YoutubeDlDownloadStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '继续',
              onPressed: onResume,
              icon: const Icon(Icons.play_circle_outline, size: 20),
            ),
            IconButton(
              tooltip: '取消',
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined, size: 20),
            ),
          ],
        );
      case YoutubeDlDownloadStatus.done:
      case YoutubeDlDownloadStatus.failed:
      case YoutubeDlDownloadStatus.cancelled:
      case YoutubeDlDownloadStatus.needsMuxer:
        return IconButton(
          tooltip: '删除',
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline, size: 20),
        );
    }
  }

  IconData _icon(YoutubeDlDownloadStatus status) {
    switch (status) {
      case YoutubeDlDownloadStatus.pending:
        return Icons.schedule;
      case YoutubeDlDownloadStatus.running:
        return Icons.downloading;
      case YoutubeDlDownloadStatus.paused:
        return Icons.pause_circle_outline;
      case YoutubeDlDownloadStatus.done:
        return Icons.check_circle_outline;
      case YoutubeDlDownloadStatus.failed:
        return Icons.error_outline;
      case YoutubeDlDownloadStatus.cancelled:
        return Icons.cancel_outlined;
      case YoutubeDlDownloadStatus.needsMuxer:
        return Icons.merge_type;
    }
  }

  Color _color(BuildContext context, YoutubeDlDownloadStatus status) {
    final colors = Theme.of(context).colorScheme;
    switch (status) {
      case YoutubeDlDownloadStatus.done:
        return colors.primary;
      case YoutubeDlDownloadStatus.failed:
        return colors.error;
      case YoutubeDlDownloadStatus.cancelled:
        return colors.outline;
      case YoutubeDlDownloadStatus.needsMuxer:
        return colors.tertiary;
      case YoutubeDlDownloadStatus.pending:
      case YoutubeDlDownloadStatus.running:
      case YoutubeDlDownloadStatus.paused:
        return colors.primary;
    }
  }
}
