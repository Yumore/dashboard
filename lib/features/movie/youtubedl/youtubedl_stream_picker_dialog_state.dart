import 'package:dashboard/features/movie/youtubedl/youtubedl_audio_only_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_plan.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_muxed_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_filter.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_picker_dialog.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_video_only_stream_info.dart';
import 'package:flutter/material.dart';

class YoutubeDlStreamPickerDialogState
    extends State<YoutubeDlStreamPickerDialog> {
  YoutubeDlStreamFilter _filter = YoutubeDlStreamFilter.all;
  YoutubeDlVideoOnlyStreamInfo? _video;
  YoutubeDlAudioOnlyStreamInfo? _audio;

  List<YoutubeDlStreamInfo> get _streams => widget.manifest.filter(_filter);

  void _select(YoutubeDlStreamInfo stream) {
    if (stream is YoutubeDlVideoOnlyStreamInfo) {
      setState(() {
        _video = _video?.itag == stream.itag ? null : stream;
      });
    } else if (stream is YoutubeDlAudioOnlyStreamInfo) {
      setState(() {
        _audio = _audio?.itag == stream.itag ? null : stream;
      });
    } else if (stream is YoutubeDlMuxedStreamInfo) {
      _downloadSingle(stream);
    }
  }

  void _downloadSingle(YoutubeDlStreamInfo stream) {
    Navigator.of(context).pop(YoutubeDlDownloadPlan.single(stream));
  }

  void _downloadMerged() {
    final video = _video;
    final audio = _audio;
    if (video == null || audio == null) return;
    Navigator.of(
      context,
    ).pop(YoutubeDlDownloadPlan.merged(video: video, audio: audio));
  }

  bool _isSelected(YoutubeDlStreamInfo stream) {
    return identical(stream, _video) || identical(stream, _audio);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        widget.video.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('筛选：'),
                const SizedBox(width: 8),
                DropdownButton<YoutubeDlStreamFilter>(
                  value: _filter,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _filter = value);
                  },
                  items: YoutubeDlStreamFilter.values
                      .map(
                        (filter) => DropdownMenuItem<YoutubeDlStreamFilter>(
                          value: filter,
                          child: Text(filter.label),
                        ),
                      )
                      .toList(growable: false),
                ),
                const Spacer(),
                if (widget.manifest.unavailableCount > 0)
                  Text(
                    '${widget.manifest.unavailableCount} 个流需签名解密，已跳过',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _streams.isEmpty
                  ? const Center(child: Text('没有匹配的直连流'))
                  : ListView.builder(
                      itemCount: _streams.length,
                      itemBuilder: (context, index) {
                        final stream = _streams[index];
                        return ListTile(
                          dense: true,
                          selected: _isSelected(stream),
                          leading: Icon(_leadingIcon(stream)),
                          title: Text(_title(stream)),
                          subtitle: Text(_subtitle(stream)),
                          trailing: IconButton(
                            tooltip: '下载此流',
                            icon: const Icon(Icons.download_outlined),
                            onPressed: () => _downloadSingle(stream),
                          ),
                          onTap: () => _select(stream),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '已选：${_video?.qualityLabel ?? '视频未选'} + '
                    '${_audio?.qualityLabel ?? '音频未选'}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                FilledButton(
                  onPressed: _video != null && _audio != null
                      ? _downloadMerged
                      : null,
                  child: const Text('下载并合成'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '合成需要 FFmpeg；宿主未集成时会标记为“需要合成”，不会写入文件。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }

  IconData _leadingIcon(YoutubeDlStreamInfo stream) {
    if (stream is YoutubeDlMuxedStreamInfo) return Icons.movie_filter_outlined;
    if (stream is YoutubeDlAudioOnlyStreamInfo) {
      return Icons.audiotrack_outlined;
    }
    return Icons.videocam_outlined;
  }

  String _title(YoutubeDlStreamInfo stream) {
    if (stream is YoutubeDlMuxedStreamInfo) {
      return '视频 + 音频 · ${stream.qualityLabel} · '
          '${stream.containerLabel} · ${stream.sizeLabel}';
    }
    if (stream is YoutubeDlAudioOnlyStreamInfo) {
      return '仅音频 · ${stream.qualityLabel} · '
          '${stream.containerLabel} · ${stream.sizeLabel}';
    }
    final video = stream as YoutubeDlVideoOnlyStreamInfo;
    return '仅视频 · ${video.qualityLabel} · '
        '${video.containerLabel} · ${video.sizeLabel}';
  }

  String _subtitle(YoutubeDlStreamInfo stream) {
    if (stream is YoutubeDlMuxedStreamInfo) {
      return '${stream.videoCodec} | ${stream.audioCodec}';
    }
    if (stream is YoutubeDlAudioOnlyStreamInfo) {
      return '${stream.audioCodec} | ${stream.bitrateLabel}';
    }
    final video = stream as YoutubeDlVideoOnlyStreamInfo;
    return '${video.videoCodec} | ${video.fps} fps';
  }
}
