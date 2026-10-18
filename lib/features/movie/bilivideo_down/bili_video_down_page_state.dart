import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_api.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_controller.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_task.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_quality.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_range_downloader.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_stream_selection.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_task_status.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_task_store.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_ugc_episode.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_down_page.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_info.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_stream.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// UI for [BiliVideoDownPage]: resolve a bilibili link, pick a stream, run the
/// range downloader and play the finished file with the host's media_kit page.
///
/// No network request is issued from [build]; every request is triggered by an
/// explicit user action (resolve, quality/episode switch, download, resume).
class BiliVideoDownPageState extends State<BiliVideoDownPage> {
  static const Duration _apiTimeout = Duration(seconds: 15);

  late final bool _ownsController = widget.controller == null;
  late final BiliDownloadController _controller =
      widget.controller ?? _createController();
  final TextEditingController _input = TextEditingController();

  BiliDownloadController _createController() {
    final apiDio = Dio(
      BaseOptions(
        connectTimeout: _apiTimeout,
        receiveTimeout: _apiTimeout,
        sendTimeout: const Duration(seconds: 10),
      ),
    );
    // A whole-file download legitimately streams for minutes, so the download
    // client must not keep the metadata receive timeout. `validateStatus`
    // accepts every status because the range downloader inspects `206`/`200`
    // itself, exactly like the source app's `validateStatus: (_) => true`.
    final downloadDio = Dio(
      BaseOptions(
        connectTimeout: _apiTimeout,
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: Duration.zero,
        validateStatus: (int? status) => true,
      ),
    );
    return BiliDownloadController(
      api: BiliApi(apiDio),
      store: BiliTaskStore(),
      downloader: BiliRangeDownloader(dio: downloadDio),
      storageDirectory: widget.storageDirectory,
      now: widget.now,
      cookie: widget.cookie,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChanged);
    _input.addListener(_handleInputChanged);
    unawaited(_controller.loadTasks());
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _input.removeListener(_handleInputChanged);
    _input.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  void _handleInputChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleResolve() async {
    final input = _input.text;
    final error = BiliDownloadController.inputError(input);
    if (error != null) {
      _showMessage(error);
      return;
    }
    FocusScope.of(context).unfocus();
    await _controller.resolve(input);
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      _showMessage('剪贴板里没有文本');
      return;
    }
    _input.text = text;
    await _controller.resolve(text);
  }

  Future<void> _handleStartDownload() async {
    final task = await _controller.startDownload();
    if (task == null) {
      final error = _controller.errorMessage;
      if (error != null) _showMessage(error);
      return;
    }
    _showMessage('已加入下载：${task.displayTitle}');
  }

  void _handleSelectEpisode(BiliUgcEpisode? episode) {
    unawaited(_controller.selectEpisode(episode));
  }

  void _handleSelectQuality(int quality) {
    unawaited(_controller.selectQuality(quality));
  }

  Future<void> _handlePlay(BiliDownloadTask task) async {
    if (task.filePath.isEmpty) {
      _showMessage('该任务没有可播放的文件');
      return;
    }
    final file = File(task.filePath);
    if (!file.existsSync()) {
      _showMessage('文件不存在，可能已被移动或删除');
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaPlaybackPage(
          title: task.displayTitle,
          sources: <MediaStreamSource>[
            MediaStreamSource(label: '本地文件', url: file.uri),
          ],
        ),
      ),
    );
  }

  Future<void> _handleClearAll() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('清空下载记录'),
            content: const Text('将移除全部任务记录，已完成的文件也会一并删除。'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('清空'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await _controller.clearAll(deleteFiles: true);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final info = controller.videoInfo;
    final inputError = _input.text.trim().isEmpty
        ? null
        : BiliDownloadController.inputError(_input.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('B站视频下载'),
        actions: <Widget>[
          if (controller.tasks.isNotEmpty)
            IconButton(
              onPressed: _handleClearAll,
              tooltip: '清空下载记录',
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        children: <Widget>[
          _buildInputCard(controller, inputError),
          if (controller.isResolving) ...<Widget>[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
            const SizedBox(height: 6),
            const Text('正在解析视频信息…', textAlign: TextAlign.center),
          ],
          if (controller.errorMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            _buildMessageCard(
              controller.errorMessage!,
              isError: true,
              onDismiss: controller.clearError,
            ),
          ],
          if (controller.notice != null) ...<Widget>[
            const SizedBox(height: 12),
            _buildMessageCard(
              controller.notice!,
              isError: false,
              onDismiss: controller.clearError,
            ),
          ],
          if (info != null) ...<Widget>[
            const SizedBox(height: 12),
            _buildVideoCard(controller, info),
          ] else if (!controller.isResolving) ...<Widget>[
            const SizedBox(height: 12),
            _buildEmptyState(),
          ],
          const SizedBox(height: 20),
          _buildTaskHeader(controller),
          const SizedBox(height: 8),
          if (controller.tasks.isEmpty)
            _buildEmptyTasks()
          else
            for (final task in controller.tasks)
              _buildTaskCard(controller, task),
        ],
      ),
    );
  }

  Widget _buildInputCard(
    BiliDownloadController controller,
    String? inputError,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('视频链接 / BV 号 / AV 号'),
            const SizedBox(height: 8),
            TextField(
              controller: _input,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => unawaited(_handleResolve()),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText:
                    'https://www.bilibili.com/video/BV1xx411c7mD 或 BV1xx411c7mD',
                errorText: inputError,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                FilledButton.icon(
                  onPressed: controller.isResolving
                      ? null
                      : () => unawaited(_handleResolve()),
                  icon: const Icon(Icons.search),
                  label: const Text('解析'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: controller.isResolving
                      ? null
                      : () => unawaited(_handlePaste()),
                  icon: const Icon(Icons.content_paste),
                  label: const Text('粘贴并解析'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(
    String message, {
    required bool isError,
    VoidCallback? onDismiss,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: isError ? scheme.errorContainer : scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          children: <Widget>[
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: isError
                  ? scheme.onErrorContainer
                  : scheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError
                      ? scheme.onErrorContainer
                      : scheme.onSecondaryContainer,
                ),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                tooltip: '关闭',
                icon: const Icon(Icons.close),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: <Widget>[
            const Icon(Icons.video_library_outlined, size: 40),
            const SizedBox(height: 8),
            Text(
              '粘贴 B 站视频链接或 BV 号，解析后可选择清晰度与分 P 并下载。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!_controller.hasCookie) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                '未提供 Cookie，只能解析公开清晰度。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(
    BiliDownloadController controller,
    BiliVideoInfo info,
  ) {
    final selection = controller.selection;
    final playInfo = controller.playInfo;
    final quality =
        controller.selectedQuality ??
        selection?.defaultQuality ??
        biliDefaultQuality;
    final stream = playInfo == null
        ? null
        : BiliStreamSelection.resolve(
            playInfo,
            quality: quality,
            format: controller.selectedFormat,
          );
    final selectedEpisode =
        controller.episodes.contains(controller.selectedEpisode)
        ? controller.selectedEpisode
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 112,
                  height: 70,
                  child: info.pic.isEmpty
                      ? const ColoredBox(color: Colors.black12)
                      : CachedNetworkImage(
                          imageUrl: info.pic,
                          fit: BoxFit.cover,
                          httpHeaders: const <String, String>{
                            'Referer': BiliApi.defaultReferer,
                          },
                          placeholder: (_, _) =>
                              const ColoredBox(color: Colors.black12),
                          errorWidget: (_, _, _) =>
                              const Icon(Icons.movie_outlined),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        info.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${info.bvid.isEmpty ? 'av${info.aid}' : info.bvid}'
                        '${info.isCollection ? ' · 合集 ${controller.episodes.length} 个视频' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (controller.hasCollection) ...<Widget>[
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Text('分 P'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<BiliUgcEpisode>(
                      isExpanded: true,
                      value: selectedEpisode,
                      hint: const Text('选择分 P'),
                      items: <DropdownMenuItem<BiliUgcEpisode>>[
                        for (final episode in controller.episodes)
                          DropdownMenuItem<BiliUgcEpisode>(
                            value: episode,
                            child: Text(
                              episode.title.isEmpty
                                  ? 'av${episode.aid}'
                                  : episode.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: controller.isResolving
                          ? null
                          : _handleSelectEpisode,
                    ),
                  ),
                ],
              ),
            ],
            if (selection != null &&
                selection.qualities.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  for (final option in selection.qualities)
                    ChoiceChip(
                      label: Text(biliQualityLabel(option)),
                      selected: option == quality,
                      onSelected: controller.isResolving
                          ? null
                          : (_) => _handleSelectQuality(option),
                    ),
                ],
              ),
            ],
            if (selection != null && selection.formats.length > 1) ...<Widget>[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  for (final option in selection.formats)
                    ChoiceChip(
                      label: Text(option.label),
                      selected: option == controller.selectedFormat,
                      onSelected: (_) => controller.selectFormat(option),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              stream == null
                  ? '该清晰度没有可下载的流'
                  : '${stream.qualityLabel} · ${formatBytes(stream.size)} · ${stream.durationText}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (stream != null && stream.hasSeparateAudio) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                '该流为 DASH 分轨，需要音视频合并，暂不支持下载。',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: stream == null || stream.hasSeparateAudio
                  ? null
                  : () => unawaited(_handleStartDownload()),
              icon: const Icon(Icons.download_outlined),
              label: const Text('开始下载'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHeader(BiliDownloadController controller) {
    return Row(
      children: <Widget>[
        Text('下载任务', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 8),
        Text(
          '${controller.completedTasks.length}/${controller.tasks.length} 已完成',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyTasks() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: Text('暂无下载任务')),
    );
  }

  Widget _buildTaskCard(
    BiliDownloadController controller,
    BiliDownloadTask task,
  ) {
    final downloading = controller.isDownloading(task.bvid);
    final received = controller.receivedBytesOf(task.bvid);
    final total = controller.totalBytesOf(task.bvid);
    final actions = <Widget>[];
    if (task.isCompleted) {
      actions.add(
        TextButton.icon(
          onPressed: () => unawaited(_handlePlay(task)),
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('播放'),
        ),
      );
    } else if (downloading) {
      actions.add(
        TextButton.icon(
          onPressed: () => unawaited(controller.pauseDownload(task.bvid)),
          icon: const Icon(Icons.pause_circle_outline),
          label: const Text('暂停'),
        ),
      );
    } else {
      actions.add(
        TextButton.icon(
          onPressed: () => unawaited(controller.resumeDownload(task.bvid)),
          icon: const Icon(Icons.play_arrow_outlined),
          label: const Text('继续'),
        ),
      );
      actions.add(
        TextButton.icon(
          onPressed: () => unawaited(controller.cancelDownload(task.bvid)),
          icon: const Icon(Icons.close_outlined),
          label: const Text('取消'),
        ),
      );
    }
    actions.add(
      TextButton.icon(
        onPressed: () =>
            unawaited(controller.removeTask(task.bvid, deleteFile: true)),
        icon: const Icon(Icons.delete_outline),
        label: const Text('删除'),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    task.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusLabel(task.status),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: task.isCompleted ? 1 : task.progress,
            ),
            const SizedBox(height: 6),
            Text(
              task.isCompleted && total > 0
                  ? formatBytes(total)
                  : '${formatBytes(received)} / ${total > 0 ? formatBytes(total) : '未知'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (task.errorMessage.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                task.errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Wrap(spacing: 4, children: actions),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLabel(BiliTaskStatus status) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      BiliTaskStatus.completed => Colors.green,
      BiliTaskStatus.failed => scheme.error,
      BiliTaskStatus.downloading => scheme.primary,
      _ => scheme.outline,
    };
    return Text(status.label, style: TextStyle(color: color, fontSize: 12));
  }
}
