import 'package:dashboard/features/live/live_channel.dart';
import 'package:dashboard/features/live/billd_live_page.dart';
import 'package:dashboard/features/live/live_module_page.dart';
import 'package:dashboard/features/live/live_playlist_repository.dart';
import 'package:dashboard/features/live/live_subscription_store.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:flutter/material.dart';

class LiveModulePageState extends State<LiveModulePage> {
  final _input = TextEditingController();
  final _repository = LivePlaylistRepository();
  final _store = LiveSubscriptionStore();
  List<LiveChannel> _channels = const [];
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final url = await _store.load();
    if (!mounted || url == null) return;
    _input.text = url;
    await _load();
  }

  Future<void> _load() async {
    final source = Uri.tryParse(_input.text.trim());
    if (source == null || !<String>['http', 'https'].contains(source.scheme)) {
      setState(() => _error = '请输入 HTTP/HTTPS M3U 或 TXT 订阅地址');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final channels = await _repository.load(source);
      await _store.save(source.toString());
      if (mounted) setState(() => _channels = channels);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _play(LiveChannel channel) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaPlaybackPage(
          title: channel.name,
          sources: [
            for (var i = 0; i < channel.urls.length; i++)
              MediaStreamSource(label: '线路 ${i + 1}', url: channel.urls[i]),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<LiveChannel>>{};
    for (final channel in _channels) {
      groups.putIfAbsent(channel.group, () => []).add(channel);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('直播订阅')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.live_tv),
              title: const Text('Billd 直播'),
              subtitle: const Text('查看在线直播间'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const BilldLivePage()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _input,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'M3U / TXT 订阅地址',
              hintText: 'https://example.com/playlist.m3u',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _load(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            label: Text(_loading ? '加载中…' : '加载频道'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (!_loading && _channels.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text('输入您有权使用的直播订阅地址，加载后可按分组选择频道。'),
            ),
          for (final entry in groups.entries) ...[
            const SizedBox(height: 16),
            Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
            for (final channel in entry.value)
              ListTile(
                leading: const Icon(Icons.live_tv_outlined),
                title: Text(channel.name),
                subtitle: Text('${channel.urls.length} 条播放线路'),
                trailing: const Icon(Icons.play_arrow),
                onTap: () => _play(channel),
              ),
          ],
        ],
      ),
    );
  }
}
