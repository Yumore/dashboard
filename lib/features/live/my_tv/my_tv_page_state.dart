import 'dart:async';

import 'package:dashboard/features/live/my_tv/my_tv_channel.dart';
import 'package:dashboard/features/live/my_tv/my_tv_controller.dart';
import 'package:dashboard/features/live/my_tv/my_tv_epg_repository.dart';
import 'package:dashboard/features/live/my_tv/my_tv_page.dart';
import 'package:dashboard/features/live/my_tv/my_tv_playlist_repository.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:flutter/material.dart';

class MyTvPageState extends State<MyTvPage> {
  late final MyTvController _controller = widget.controller ?? MyTvController();
  late final MyTvPlaylistRepository _playlist =
      widget.playlistRepository ?? MyTvPlaylistRepository.production();
  late final MyTvEpgRepository? _epg =
      widget.epgRepository ??
      (widget.controller == null ? MyTvEpgRepository.production() : null);
  late final TextEditingController _source = TextEditingController(
    text: MyTvPlaylistRepository.defaultSource,
  );

  late bool _simplify = widget.simplify;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Loading starts here, never in build: build must stay network-free.
    if (!_controller.hasChannels) unawaited(_load());
  }

  Future<void> _load() async {
    final uri = Uri.tryParse(_source.text.trim());
    if (uri == null || !<String>['http', 'https'].contains(uri.scheme)) {
      setState(() => _error = '请输入 HTTP/HTTPS 直播源地址');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final groups = await _playlist.load(source: uri, simplify: _simplify);
      if (!mounted) return;
      _controller.setGroups(groups);
      setState(() => _loading = false);
      unawaited(_loadEpg());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _loadEpg() async {
    final epg = _epg;
    if (epg == null) return;
    final channels = _controller.channels.map((c) => c.tvgName).toSet();
    if (channels.isEmpty) return;
    try {
      final guide = await epg.load(channels: channels);
      if (!mounted) return;
      _controller.setGuide(guide);
    } catch (_) {
      // EPG is best-effort: playback still works without programme data.
    }
  }

  Future<void> _toggleSimplify(bool value) async {
    setState(() => _simplify = value);
    if (_controller.hasChannels) unawaited(_load());
  }

  Future<void> _play(MyTvChannel channel) async {
    if (channel.urls.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaPlaybackPage(
          title: channel.name,
          sources: [
            for (var index = 0; index < channel.urls.length; index++)
              MediaStreamSource(
                label: '线路 ${index + 1}',
                url: channel.urls[index],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _source.dispose();
    // Only dispose the controller we created ourselves.
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('我的电视 · my_tv')),
    body: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sourceCard(context),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 12),
          _currentChannelCard(context),
          const SizedBox(height: 12),
          _tunerControls(context),
          const SizedBox(height: 12),
          _numberPad(context),
          _channelList(context),
        ],
      ),
    ),
  );

  Widget _sourceCard(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _source,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: '直播源（M3U / TVbox TXT）',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => unawaited(_load()),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _loading ? null : () => unawaited(_load()),
                icon: const Icon(Icons.refresh),
                label: Text(_loading ? '加载中…' : '加载频道'),
              ),
              Expanded(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('精简为 CCTV/卫视'),
                  value: _simplify,
                  onChanged: _loading
                      ? null
                      : (value) => unawaited(_toggleSimplify(value)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _currentChannelCard(BuildContext context) {
    final channel = _controller.current;
    if (channel == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.live_tv),
          title: Text(_loading ? '正在加载直播源…' : '暂无频道'),
        ),
      );
    }
    final programmes = _controller.programmesFor(channel);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  channel.number.toString().padLeft(2, '0'),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('${channel.group} · ${channel.tvgName}'),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '播放',
                  icon: const Icon(Icons.play_circle),
                  onPressed: channel.urls.isEmpty
                      ? null
                      : () => unawaited(_play(channel)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              programmes.current.isEmpty
                  ? '暂无节目单'
                  : '正在播出：${programmes.current}',
            ),
            if (programmes.next.isNotEmpty) Text('下一档：${programmes.next}'),
          ],
        ),
      ),
    );
  }

  Widget _tunerControls(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      OutlinedButton(
        onPressed: _controller.previousGroupChannel,
        child: const Text('上一组'),
      ),
      FilledButton.tonal(
        onPressed: _controller.previousChannel,
        child: const Text('上一个'),
      ),
      FilledButton.tonal(
        onPressed: _controller.nextChannel,
        child: const Text('下一个'),
      ),
      OutlinedButton(
        onPressed: _controller.nextGroupChannel,
        child: const Text('下一组'),
      ),
    ],
  );

  Widget _numberPad(BuildContext context) {
    final channelNo = _controller.channelNo;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('数字选台', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              channelNo.isEmpty ? '输入频道号…' : channelNo,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text('${_controller.confirmSeconds} 秒后自动确认，可继续输入'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var digit = 0; digit <= 9; digit++)
                  SizedBox(
                    width: 48,
                    child: OutlinedButton(
                      onPressed: () => _controller.inputChannelNo('$digit'),
                      child: Text('$digit'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _channelList(BuildContext context) {
    if (!_controller.hasChannels) return const SizedBox.shrink();
    final current = _controller.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in _controller.groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              '${group.name}（${group.channels.length}）',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final channel in group.channels)
            ListTile(
              dense: true,
              selected: current?.number == channel.number,
              leading: CircleAvatar(
                radius: 14,
                child: Text('${channel.number}'),
              ),
              title: Text(channel.name),
              subtitle: Text(
                '${channel.urls.length} 条线路 · EPG ${channel.tvgName}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: channel.urls.isEmpty
                    ? null
                    : () => unawaited(_play(channel)),
              ),
              onTap: () => _controller.select(channel),
            ),
        ],
      ],
    );
  }
}
