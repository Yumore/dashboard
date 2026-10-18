import 'dart:async';

import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_dedup.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_lapse_cover_fix.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_tools_page.dart';
import 'package:flutter/material.dart';

/// State of [AnimeTraceToolsPage]: duplicate-name cleanup and lapsed-cover
/// repair, both driven by the pure planners in `animetrace_dedup.dart` and
/// `animetrace_lapse_cover_fix.dart`.
class AnimeTraceToolsPageState extends State<AnimeTraceToolsPage> {
  List<AnimeTraceDedupGroup> _groups = const <AnimeTraceDedupGroup>[];
  Set<int> _selected = const <int>{};
  List<AnimeTraceAnime> _lapsed = const <AnimeTraceAnime>[];

  bool _loading = true;
  bool _busy = false;
  String? _error;
  String _message = '';

  @override
  void initState() {
    super.initState();
    unawaited(_loadDups());
  }

  Future<void> _loadDups() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final dupAnimes = await widget.animeDao.getDupAnimes();
      if (!mounted) return;
      setState(() {
        _groups = AnimeTraceDedup.groupByName(dupAnimes);
        _selected = AnimeTraceDedup.idsWithoutProgress(dupAnimes);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      for (final id in _selected) {
        await widget.animeDao.deleteAnimeById(id);
      }
      final result = AnimeTraceDedup.removeSelected(_groups, _selected);
      if (!mounted) return;
      setState(() {
        _groups = result.groups;
        _selected = const <int>{};
        _message =
            '已删除 ${result.deletedIds.length} 条，剩余 ${result.totalCount} 条';
        _busy = false;
      });
      widget.onChanged();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _busy = false;
      });
    }
  }

  Future<void> _checkLapsedCovers() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = '';
    });
    try {
      final all = await widget.animeDao.getAllAnimes();
      final lapsed = await AnimeTraceLapseCoverFix.detectLapsed(
        all,
        reachable: (url) => widget.repository.probe.isReachable(url),
      );
      if (!mounted) return;
      setState(() {
        _lapsed = lapsed;
        _message = lapsed.isEmpty ? '没有找到失效封面。' : '发现 ${lapsed.length} 个失效封面';
        _busy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _busy = false;
      });
    }
  }

  Future<void> _repairLapsedCovers() async {
    if (_lapsed.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _message = '';
    });
    var repaired = 0;
    var failed = 0;
    try {
      for (final batch in AnimeTraceLapseCoverFix.batches(_lapsed)) {
        for (final anime in batch) {
          try {
            final refreshed = await widget.repository.climbAnimeInfo(anime);
            if (refreshed.animeCoverUrl.isNotEmpty) {
              await widget.animeDao.updateAnimeCoverUrl(
                anime.animeId,
                refreshed.animeCoverUrl,
              );
              repaired++;
            }
          } catch (_) {
            failed++;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _lapsed = const <AnimeTraceAnime>[];
        _message = '封面修复完成：$repaired 成功，$failed 失败';
        _busy = false;
      });
      widget.onChanged();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('维护工具')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '出错了：$_error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_message),
                  ),
                const _SectionHeader('重复条目'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: _groups.isEmpty
                            ? null
                            : () {
                                final ids = AnimeTraceDedup.idsWithoutProgress(
                                  <AnimeTraceAnime>[
                                    for (final group in _groups)
                                      ...group.animes,
                                  ],
                                );
                                setState(() => _selected = ids);
                              },
                        child: const Text('选择无进度'),
                      ),
                      TextButton(
                        onPressed: _selected.isEmpty
                            ? null
                            : () => setState(() => _selected = <int>{}),
                        child: const Text('清空选择'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _selected.isEmpty || _busy
                            ? null
                            : () => unawaited(_deleteSelected()),
                        child: Text('删除选中(${_selected.length})'),
                      ),
                    ],
                  ),
                ),
                if (_groups.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('没有重复条目。'),
                  )
                else
                  for (final group in _groups)
                    ExpansionTile(
                      title: Text('${group.name}（${group.length}）'),
                      children: <Widget>[
                        for (final anime in group.animes)
                          CheckboxListTile(
                            dense: true,
                            value: _selected.contains(anime.animeId),
                            title: Text(
                              '已看 ${anime.checkedEpisodeCnt} 集 · '
                              '${anime.animeUrl}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onChanged: (checked) {
                              setState(() {
                                final next = <int>{..._selected};
                                if (checked == true) {
                                  next.add(anime.animeId);
                                } else {
                                  next.remove(anime.animeId);
                                }
                                _selected = next;
                              });
                            },
                          ),
                      ],
                    ),
                const Divider(),
                const _SectionHeader('失效封面'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => unawaited(_checkLapsedCovers()),
                        child: const Text('检测失效封面'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _lapsed.isEmpty || _busy
                            ? null
                            : () => unawaited(_repairLapsedCovers()),
                        child: Text('修复封面(${_lapsed.length})'),
                      ),
                    ],
                  ),
                ),
                if (_lapsed.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('尚未检测，或没有失效封面。'),
                  )
                else
                  for (final anime in _lapsed)
                    ListTile(
                      dense: true,
                      title: Text(anime.animeName),
                      subtitle: Text(
                        anime.animeCoverUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
