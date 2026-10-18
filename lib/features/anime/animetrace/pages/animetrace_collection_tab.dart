import 'dart:async';

import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_label.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_refresh_bus.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_anime_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_image_store.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_label_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_series_dao.dart';
import 'package:dashboard/features/anime/animetrace/widgets/animetrace_cover.dart';
import 'package:dashboard/features/anime/animetrace/widgets/animetrace_label_picker.dart';
import 'package:flutter/material.dart';

/// The collection tab: every locally collected anime, filterable by tag and by
/// label, with label editing and series membership.
class AnimeTraceCollectionTab extends StatefulWidget {
  const AnimeTraceCollectionTab({
    required this.animeDao,
    required this.labelDao,
    required this.seriesDao,
    required this.imageStore,
    required this.bus,
    required this.onOpenAnime,
    super.key,
  });

  final AnimeTraceAnimeDao animeDao;
  final AnimeTraceLabelDao labelDao;
  final AnimeTraceSeriesDao seriesDao;
  final AnimeTraceImageStore imageStore;
  final AnimeTraceRefreshBus bus;
  final void Function(AnimeTraceAnime anime) onOpenAnime;

  @override
  State<AnimeTraceCollectionTab> createState() =>
      _AnimeTraceCollectionTabState();
}

class _AnimeTraceCollectionTabState extends State<AnimeTraceCollectionTab> {
  List<AnimeTraceAnime> _animes = const <AnimeTraceAnime>[];
  List<AnimeTraceLabel> _labels = const <AnimeTraceLabel>[];
  Set<int> _labeledAnimeIds = const <int>{};
  String _coverRoot = '';
  String _tagFilter = '';
  int _labelFilter = -1;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.bus.addListener(_load);
    unawaited(_load());
  }

  @override
  void dispose() {
    widget.bus.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final coverRoot = await widget.imageStore.coverImageRootDirPath();
      final animes = await widget.animeDao.getAllAnimes();
      final labels = await widget.labelDao.getAll();
      if (!mounted) return;
      setState(() {
        _coverRoot = coverRoot;
        _animes = animes;
        _labels = labels;
        _loading = false;
      });
      await _applyLabelFilter(_labelFilter);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _applyLabelFilter(int labelId) async {
    if (labelId == -1) {
      if (!mounted) return;
      setState(() {
        _labelFilter = -1;
        _labeledAnimeIds = const <int>{};
      });
      return;
    }
    final ids = await widget.labelDao.getAnimeIdsByLabelId(labelId);
    if (!mounted) return;
    setState(() {
      _labelFilter = labelId;
      _labeledAnimeIds = ids.toSet();
    });
  }

  List<String> get _tags {
    final tags = <String>{};
    for (final anime in _animes) {
      if (anime.tagName.isNotEmpty) tags.add(anime.tagName);
    }
    return tags.toList()..sort();
  }

  List<AnimeTraceAnime> get _visibleAnimes {
    Iterable<AnimeTraceAnime> visible = _animes;
    if (_tagFilter.isNotEmpty) {
      visible = visible.where((anime) => anime.tagName == _tagFilter);
    }
    if (_labelFilter != -1) {
      visible = visible.where(
        (anime) => _labeledAnimeIds.contains(anime.animeId),
      );
    }
    return visible.toList();
  }

  Future<void> _editLabels(AnimeTraceAnime anime) async {
    final selected = await AnimeTraceLabelPicker.show(
      context,
      labelDao: widget.labelDao,
      animeId: anime.animeId,
    );
    if (selected == null || !mounted) return;
    await widget.labelDao.setAnimeLabels(anime.animeId, selected);
    await _load();
    widget.bus.notifyChanged();
  }

  Future<void> _editSeries(AnimeTraceAnime anime) async {
    final series = await widget.seriesDao.getAll();
    if (!mounted) return;
    final current = await widget.seriesDao.getSeriesIdsByAnimeId(anime.animeId);
    if (!mounted) return;
    final choice = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('加入系列'),
        children: <Widget>[
          for (final item in series)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(item.id),
              child: Row(
                children: <Widget>[
                  Icon(
                    current.contains(item.id)
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.name)),
                ],
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop(-2),
            child: const Text('新建系列…'),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;

    var seriesId = choice;
    if (seriesId == -2) {
      final controller = TextEditingController();
      final name = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('新建系列'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: '系列名称'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('创建'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (name == null || name.isEmpty) return;
      seriesId = await widget.seriesDao.insert(name);
    }
    if (seriesId <= 0) return;

    if (current.contains(seriesId)) {
      await widget.seriesDao.deleteAnimeFromSeries(anime.animeId, seriesId);
    } else {
      await widget.seriesDao.addAnimeToSeries(anime.animeId, seriesId);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已更新系列归属')));
  }

  Future<void> _delete(AnimeTraceAnime anime) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除收藏'),
        content: Text('删除「${anime.animeName}」及其观看记录和笔记？'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.animeDao.deleteAnimeById(anime.animeId);
    await _load();
    widget.bus.notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
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
              Text('加载失败：$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => unawaited(_load()),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    final visible = _visibleAnimes;
    return Column(
      children: <Widget>[
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: <Widget>[
              _chip('全部', _tagFilter.isEmpty && _labelFilter == -1, () {
                setState(() => _tagFilter = '');
                unawaited(_applyLabelFilter(-1));
              }),
              for (final tag in _tags)
                _chip(tag, _tagFilter == tag, () {
                  setState(() => _tagFilter = tag);
                  unawaited(_applyLabelFilter(-1));
                }),
              for (final label in _labels)
                _chip('标签·${label.name}', _labelFilter == label.id, () {
                  unawaited(_applyLabelFilter(label.id));
                }),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text('暂无收藏，去"搜索"里添加吧'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final anime = visible[index];
                      return ListTile(
                        leading: AnimeTraceCover(
                          url: anime.animeCoverUrl,
                          localRoot: _coverRoot,
                        ),
                        title: Text(anime.animeName),
                        subtitle: Text(
                          '已看 ${anime.checkedEpisodeCnt} / '
                          '${anime.animeEpisodeCnt} 集'
                          '${anime.tagName.isEmpty ? '' : ' · ${anime.tagName}'}',
                        ),
                        onTap: () => widget.onOpenAnime(anime),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'labels':
                                unawaited(_editLabels(anime));
                              case 'series':
                                unawaited(_editSeries(anime));
                              case 'delete':
                                unawaited(_delete(anime));
                            }
                          },
                          itemBuilder: (_) => const <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'labels',
                              child: Text('标签'),
                            ),
                            PopupMenuItem<String>(
                              value: 'series',
                              child: Text('系列'),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('删除'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
