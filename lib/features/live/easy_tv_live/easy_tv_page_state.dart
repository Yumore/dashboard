import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog_repository.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_channel.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_page.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_playback_controller.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_settings_store.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_source.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_source_page.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_source_store.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:flutter/material.dart';

class EasyTvPageState extends State<EasyTvPage> {
  late final EasyTvCatalogRepository _repository =
      widget.repository ?? EasyTvCatalogRepository();
  late final EasyTvSourceStore _sourceStore =
      widget.sourceStore ?? const EasyTvSourceStore();
  late final EasyTvSettingsStore _settingsStore =
      widget.settingsStore ?? const EasyTvSettingsStore();

  List<EasyTvSource> _sources = const <EasyTvSource>[];
  EasyTvSource? _source;
  EasyTvCatalog? _catalog;
  EasyTvPlaybackController? _playback;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    if (widget.repository == null) _repository.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stored = await _sourceStore.load();
      final sources = stored.isEmpty
          ? <EasyTvSource>[
              const EasyTvSource(
                link: EasyTvSource.defaultLink,
                selected: true,
              ),
            ]
          : stored;
      if (stored.isEmpty) await _sourceStore.save(sources);
      final source = EasyTvSourceStore.selectedOrDefault(sources);
      final lastSerial = await _settingsStore.loadPrePlaySerial();
      final catalog = await _repository.load(source.link);
      if (!mounted) return;
      final playback = EasyTvPlaybackController(
        catalog: catalog,
        serialNum: lastSerial,
      );
      setState(() {
        _sources = sources;
        _source = source;
        _catalog = catalog;
        _playback = playback;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _describe(error);
        _loading = false;
      });
    }
  }

  String _describe(Object error) {
    if (error is FormatException) return error.message;
    final text = '$error';
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  Future<void> _reload() async {
    final catalog = _catalog;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final source = _source ?? EasyTvSourceStore.selectedOrDefault(_sources);
      final fresh = await _repository.load(source.link);
      if (!mounted) return;
      setState(() {
        _catalog = fresh;
        _playback?.setCatalog(fresh);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _error = _describe(error);
        _loading = false;
      });
    }
  }

  Future<void> _openSourcePage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EasyTvSourcePage(sourceStore: _sourceStore),
      ),
    );
    if (!mounted) return;
    await _bootstrap();
  }

  Future<void> _play(EasyTvChannel channel) async {
    final playback = _playback;
    if (playback == null || channel.urls.isEmpty) return;
    playback.openSerial(channel.serialNum);
    await _settingsStore.savePrePlaySerial(channel.serialNum);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _playerPage(playback, channel)),
    );
  }

  Widget _playerPage(EasyTvPlaybackController playback, EasyTvChannel channel) {
    final header = playback.requestHeaders;
    final channels = _catalog?.channels ?? const <EasyTvChannel>[];
    final index = channels.indexWhere(
      (item) => item.serialNum == channel.serialNum,
    );
    final previous = index > 0 ? channels[index - 1] : null;
    final next = index >= 0 && index + 1 < channels.length
        ? channels[index + 1]
        : null;
    return MediaPlaybackPage(
      title: channel.title,
      sources: <MediaStreamSource>[
        for (var i = 0; i < channel.urls.length; i++)
          MediaStreamSource(
            label: '线路 ${i + 1}',
            url: channel.urls[i],
            headers: header,
          ),
      ],
      previousPage: previous == null
          ? null
          : (_) => _playerPage(playback, previous),
      nextPage: next == null ? null : (_) => _playerPage(playback, next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _catalog;
    final playback = _playback;
    final channel = playback?.channel;
    return Scaffold(
      appBar: AppBar(
        title: Text(channel?.title ?? '电视直播'),
        actions: [
          IconButton(
            tooltip: '刷新节目单',
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: '订阅源',
            onPressed: _openSourcePage,
            icon: const Icon(Icons.settings_ethernet),
          ),
        ],
      ),
      drawer: catalog == null
          ? null
          : Drawer(child: SafeArea(child: _catalogDrawer(catalog, channel))),
      body: Center(child: _body(catalog, channel)),
    );
  }

  Widget _body(EasyTvCatalog? catalog, EasyTvChannel? channel) {
    if (_loading) return const CircularProgressIndicator();
    final error = _error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('加载失败：$error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: _bootstrap, child: const Text('重试')),
            const SizedBox(height: 8),
            TextButton(onPressed: _openSourcePage, child: const Text('更换订阅源')),
          ],
        ),
      );
    }
    if (catalog == null || channel == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('订阅中没有可播放频道'),
            const SizedBox(height: 8),
            TextButton(onPressed: _openSourcePage, child: const Text('更换订阅源')),
          ],
        ),
      );
    }
    final lines = channel.urls.length;
    final groupName =
        channel.groupIndex >= 0 && channel.groupIndex < catalog.groups.length
        ? catalog.groups[channel.groupIndex].name
        : '';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(channel.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('分组：$groupName'),
          Text('线路：$lines'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: lines == 0 ? null : () => _play(channel),
            icon: const Icon(Icons.play_arrow),
            label: const Text('播放'),
          ),
          const SizedBox(height: 8),
          Text(
            '共 ${catalog.channelCount} 个频道 · ${catalog.groups.length} 个分组',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          const Text('打开左上角菜单切换分组与频道'),
        ],
      ),
    );
  }

  Widget _catalogDrawer(EasyTvCatalog catalog, EasyTvChannel? current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _source?.isDefault == true ? '默认公共源' : (_source?.link ?? '未选择'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: catalog.groups.length,
            itemBuilder: (context, groupIndex) {
              final group = catalog.groups[groupIndex];
              return ExpansionTile(
                key: ValueKey<int>(group.index),
                initiallyExpanded: group.channels.any(
                  (item) => item.serialNum == current?.serialNum,
                ),
                title: Text('${group.name}（${group.channels.length}）'),
                children: [
                  for (final channel in group.channels)
                    ListTile(
                      dense: true,
                      selected: channel.serialNum == current?.serialNum,
                      title: Text('${channel.serialNum} ${channel.title}'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _play(channel);
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
