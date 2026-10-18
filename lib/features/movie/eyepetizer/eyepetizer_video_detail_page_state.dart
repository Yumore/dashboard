import 'dart:async';

import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_consumption.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_data.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_exception.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_load_state.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_playback.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_relate_widget_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_status_view.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_thumbnail.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_video_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EyepetizerVideoDetailPageState extends State<EyepetizerVideoDetailPage> {
  late final EyepetizerApi _api;
  late final bool _ownsApi;

  final EyepetizerLoadState<List<EyepetizerItem>> _related =
      EyepetizerLoadState<List<EyepetizerItem>>();

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? EyepetizerApi();
    unawaited(_loadRelated());
  }

  @override
  void dispose() {
    if (_ownsApi) _api.dispose();
    super.dispose();
  }

  Future<void> _loadRelated() async {
    setState(() {
      _related.loading = true;
      _related.error = null;
    });
    try {
      final issue = await _api.related(widget.data.id);
      if (!mounted) return;
      setState(() {
        _related.data = issue.itemList;
        _related.loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _related.loading = false;
        _related.error = error is EyepetizerException
            ? error.message
            : '相关推荐加载失败';
      });
    }
  }

  /// Playback: prefer a real stream URL, fall back to the Kaiyan share page.
  ///
  /// The source only ever had `data.playUrl`; `EyepetizerPlayback` additionally
  /// exposes `data.playInfo[].urlList` so the host player can offer qualities.
  Future<void> _play() async {
    final playback = EyepetizerPlayback.from(widget.data);
    if (playback.hasStream) {
      final handler = widget.onPlay;
      if (handler != null) {
        await handler(context, widget.data, playback.sources);
        return;
      }
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => MediaPlaybackPage(
            title: widget.data.title,
            sources: playback.sources,
            historyId: 'eyepetizer-${widget.data.id}',
          ),
        ),
      );
      return;
    }
    final external = playback.externalUrl;
    if (external == null) {
      _showMessage('该视频没有可播放的地址');
      return;
    }
    final opener = widget.onOpenExternal;
    final opened = opener != null
        ? await opener(external)
        : await launchUrl(external, mode: LaunchMode.externalApplication);
    if (!opened) _showMessage('无法打开外部链接：$external');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _openRelated(EyepetizerItem item) {
    final data = item.data;
    if (data == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => EyepetizerVideoDetailPage(data: data, api: _api),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Scaffold(
      appBar: AppBar(
        title: Text(data.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            tooltip: '播放',
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () => unawaited(_play()),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _hero(context, data),
          _meta(context, data),
          const Divider(height: 1),
          ..._relatedSection(context),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, EyepetizerData data) {
    final cover = data.cover;
    final url = (cover?.detail.isNotEmpty ?? false)
        ? cover!.detail
        : cover?.feed;
    // Fixed height so the play affordance keeps its slot even while the
    // thumbnail is still loading (the source's video area was fixed too).
    return SizedBox(
      height: 210,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          EyepetizerThumbnail(url: url, fit: BoxFit.cover),
          Center(
            child: FilledButton.icon(
              onPressed: () => unawaited(_play()),
              icon: const Icon(Icons.play_arrow),
              label: const Text('播放'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(BuildContext context, EyepetizerData data) {
    final theme = Theme.of(context);
    final consumption = data.consumption ?? const EyepetizerConsumption();
    final dateLabel = data.dateLabel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(data.title, style: theme.textTheme.titleMedium),
              ),
              Text(
                data.category,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              EyepetizerThumbnail(
                url: data.authorIcon,
                width: 34,
                height: 34,
                circle: true,
                placeholderIcon: Icons.person_outline,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.authorLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (dateLabel.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              dateLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            <String>[
              '分享 ${consumption.shareCount}',
              '评论 ${consumption.replyCount}',
              '收藏 ${consumption.collectionCount}',
            ].join('   '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (data.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(data.description, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  List<Widget> _relatedSection(BuildContext context) {
    if (_related.loading) {
      return const <Widget>[
        SizedBox(height: 160, child: EyepetizerStatusView.loading()),
      ];
    }
    final error = _related.error;
    if (error != null) {
      return <Widget>[
        SizedBox(
          height: 160,
          child: EyepetizerStatusView.error(error, onRetry: _loadRelated),
        ),
      ];
    }
    final items = _related.data ?? const <EyepetizerItem>[];
    if (items.isEmpty) {
      return const <Widget>[
        SizedBox(height: 140, child: EyepetizerStatusView.empty('暂无相关推荐')),
      ];
    }
    return <Widget>[
      for (final item in items)
        EyepetizerRelateWidgetItem(item: item, onTap: () => _openRelated(item)),
    ];
  }
}
