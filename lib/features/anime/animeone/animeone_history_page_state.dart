import 'package:dashboard/features/anime/animeone/animeone_history_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_playback_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_entry.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

class AnimeOneHistoryPageState extends State<AnimeOneHistoryPage> {
  late final AnimeOneWatchStore _store;

  List<AnimeOneWatchEntry> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _store = widget.watchStore ?? AnimeOneWatchStore();
    _load();
  }

  Future<void> _load() async {
    await _store.load();
    if (!mounted) return;
    setState(() {
      history = List.of(_store.entries);
      loading = false;
    });
  }

  /// mm:ss 形式的时长。
  static String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空观看记录'),
        content: const Text('确定要删除全部观看记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _store.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('观看记录'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: '清空观看记录',
              onPressed: _clear,
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text('还没有观看记录'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) => _renderTile(history[index]),
            ),
    );
  }

  Widget _renderTile(AnimeOneWatchEntry entry) {
    final theme = Theme.of(context);
    final percent = (entry.progress * 100).toStringAsFixed(0);
    return ListTile(
      leading: Icon(
        entry.done ? Icons.check_circle : Icons.play_circle_outline,
        color: entry.done
            ? theme.colorScheme.tertiary
            : theme.colorScheme.secondary,
      ),
      title: Text(
        entry.episodeName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${formatDuration(entry.positionSec)} / '
        '${formatDuration(entry.durationSec)} · ${entry.done ? '已看完' : '$percent%'}',
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => AnimeOnePlaybackPage(
              link: entry.episodeLink,
              title: entry.episodeName,
              client: widget.client,
              watchStore: _store,
            ),
          ),
        ).then((_) => _load());
      },
    );
  }
}
