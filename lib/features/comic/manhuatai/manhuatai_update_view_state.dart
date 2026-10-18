import 'package:dashboard/features/comic/manhuatai/manhuatai_comic_tile.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_detail_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_image_url.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_status_view.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_update_entry.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_update_group.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_update_list.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_update_view.dart';
import 'package:flutter/material.dart';

class ManhuataiUpdateViewState extends State<ManhuataiUpdateView> {
  bool _loading = true;
  String? _error;
  ManhuataiUpdateList _updateList = ManhuataiUpdateList.empty;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.source.updateList();
      if (!mounted) {
        return;
      }
      setState(() {
        _updateList = list;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  void _openEntry(ManhuataiUpdateEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ManhuataiDetailPage(
          comicId: entry.comicId,
          source: widget.source,
          store: widget.store,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ManhuataiStatusView(loading: true);
    }
    if (_error != null) {
      return ManhuataiStatusView(message: _error, onRetry: _load);
    }
    final groups = <ManhuataiUpdateGroup>[
      ..._updateList.today,
      ..._updateList.update,
    ];
    if (groups.isEmpty) {
      return ManhuataiStatusView(message: '暂无更新', onRetry: _load);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final title = group.comicUpdateDateNew.isNotEmpty
              ? group.comicUpdateDateNew
              : group.comicUpdateDate;
          final isToday = index < _updateList.today.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
                child: Text(
                  isToday && title.isEmpty ? '今日更新' : title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ...group.info.map(
                (entry) => ManhuataiComicTile(
                  title: entry.comicName,
                  imageUrl: ManhuataiImageUrl.cover(comicId: entry.comicId),
                  subtitle: entry.comicChapterName,
                  trailing: Text(
                    entry.updateTime,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  onTap: () => _openEntry(entry),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
