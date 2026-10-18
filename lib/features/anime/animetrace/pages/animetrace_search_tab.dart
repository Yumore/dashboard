import 'dart:async';

import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_import.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_refresh_bus.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_repository.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_source.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_anime_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_label_dao.dart';
import 'package:dashboard/features/anime/animetrace/widgets/animetrace_cover.dart';
import 'package:flutter/material.dart';

/// Cross-source keyword search, with one-tap import into the local collection.
class AnimeTraceSearchTab extends StatefulWidget {
  const AnimeTraceSearchTab({
    required this.repository,
    required this.animeDao,
    required this.labelDao,
    required this.bus,
    required this.onOpenAnime,
    super.key,
  });

  final AnimeTraceRepository repository;
  final AnimeTraceAnimeDao animeDao;
  final AnimeTraceLabelDao labelDao;
  final AnimeTraceRefreshBus bus;
  final void Function(AnimeTraceAnime anime) onOpenAnime;

  @override
  State<AnimeTraceSearchTab> createState() => _AnimeTraceSearchTabState();
}

class _AnimeTraceSearchTabState extends State<AnimeTraceSearchTab> {
  final TextEditingController _keywordController = TextEditingController();

  List<AnimeTraceSource> _sources = const <AnimeTraceSource>[];
  AnimeTraceSearchResult? _result;
  bool _searching = false;
  bool _importing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSources());
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _loadSources() async {
    try {
      final sources = await widget.repository.loadSources();
      if (!mounted) return;
      setState(() => _sources = sources);
    } catch (_) {
      // The source list is only used for display; search still works.
    }
  }

  Future<void> _search() async {
    final keyword = _keywordController.text.trim();
    if (keyword.isEmpty || _searching) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final result = await widget.repository.search(
        keyword,
        sources: _sources.isEmpty ? null : _sources,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _searching = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _searching = false;
      });
    }
  }

  Future<void> _import(AnimeTraceAnime anime, {bool openAfter = true}) async {
    if (_importing) return;
    setState(() => _importing = true);
    try {
      final url = anime.animeUrl;
      final existing = url.isEmpty
          ? null
          : await widget.animeDao.getAnimeByAnimeUrl(url);
      final nameTaken = await widget.animeDao.existAnimeName(anime.animeName);
      final decision = AnimeTraceImport.decide(
        anime,
        existingUrls: <String>{if (existing != null) url},
        existingNames: <String>{if (nameTaken) anime.animeName},
      );

      if (decision != AnimeTraceImportDecision.insert) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              decision == AnimeTraceImportDecision.skipDuplicateUrl
                  ? '已经收藏过这部作品'
                  : '已存在同名作品，已跳过（可在去重页清理）',
            ),
          ),
        );
        if (openAfter && existing != null) widget.onOpenAnime(existing);
        return;
      }

      final newId = await widget.animeDao.insertAnime(
        anime.copyWith(tagName: anime.tagName.isEmpty ? '收集' : anime.tagName),
      );
      if (!mounted) return;
      widget.bus.notifyChanged();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已加入收藏')));
      if (openAfter && newId > 0) {
        widget.onOpenAnime(anime.copyWith(animeId: newId));
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('收藏失败：$error')));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _keywordController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => unawaited(_search()),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: '搜索动画名称',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _searching ? null : () => unawaited(_search()),
                child: Text(_searching ? '搜索中' : '搜索'),
              ),
            ],
          ),
        ),
        if (result != null && result.hasErrors)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '部分来源失败：${result.errors.entries.map((e) => '${e.key}(${e.value})').join('；')}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const Divider(height: 1),
        Expanded(child: _buildBody(result)),
      ],
    );
  }

  Widget _buildBody(AnimeTraceSearchResult? result) {
    if (_searching) return const Center(child: CircularProgressIndicator());
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text('搜索失败：$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => unawaited(_search()),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    if (result == null) {
      final enabled = _sources.where((s) => s.enable && !s.discard).length;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            enabled == 0
                ? '没有启用的来源，先去"来源"标签页启用一个。'
                : '将对 $enabled 个来源搜索，输入关键词后点"搜索"。',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (result.animes.isEmpty) {
      return const Center(child: Text('没有找到结果'));
    }
    return ListView.separated(
      itemCount: result.animes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final anime = result.animes[index];
        return ListTile(
          leading: AnimeTraceCover(url: anime.animeCoverUrl),
          title: Text(anime.animeName),
          subtitle: Text(
            <String>[
              if (anime.infoFirstLine.isNotEmpty) anime.infoFirstLine,
              if (anime.playStatus.isNotEmpty) anime.playStatus,
              anime.animeUrl,
            ].join('\n'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          trailing: FilledButton(
            onPressed: _importing ? null : () => unawaited(_import(anime)),
            child: const Text('收藏'),
          ),
        );
      },
    );
  }
}
