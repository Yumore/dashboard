import 'package:dashboard/features/comic/manhuatai/manhuatai_comic_tile.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_detail_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_favorite.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_read_record.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_status_view.dart';
import 'package:flutter/material.dart';

class ManhuataiLibraryPageState extends State<ManhuataiLibraryPage> {
  late int _tab = widget.initialTab;
  bool _loading = true;
  List<ManhuataiFavorite> _favorites = <ManhuataiFavorite>[];
  List<ManhuataiReadRecord> _history = <ManhuataiReadRecord>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final favorites = await widget.store.favorites();
    final history = await widget.store.history();
    if (!mounted) {
      return;
    }
    setState(() {
      _favorites = favorites;
      _history = history;
      _loading = false;
    });
  }

  Future<void> _removeFavorite(ManhuataiFavorite favorite) async {
    await widget.store.toggleFavorite(favorite);
    await _load();
  }

  Future<void> _removeHistory(ManhuataiReadRecord record) async {
    await widget.store.removeHistory(record.comicId);
    await _load();
  }

  void _openDetail(int comicId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ManhuataiDetailPage(
          comicId: comicId,
          source: widget.source,
          store: widget.store,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          onTap: (index) => setState(() => _tab = index),
          tabs: const <Widget>[
            Tab(text: '收藏'),
            Tab(text: '历史'),
          ],
        ),
        Expanded(
          child: _loading
              ? const ManhuataiStatusView(loading: true)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _tab == 0 ? _buildFavorites() : _buildHistory(),
                ),
        ),
      ],
    );
  }

  Widget _buildFavorites() {
    if (_favorites.isEmpty) {
      return ManhuataiStatusView(message: '还没有收藏');
    }
    return ListView.builder(
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final favorite = _favorites[index];
        return ManhuataiComicTile(
          title: favorite.comicName,
          imageUrl: favorite.imgUrl,
          onTap: () => _openDetail(favorite.comicId),
          trailing: IconButton(
            tooltip: '取消收藏',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _removeFavorite(favorite),
          ),
        );
      },
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) {
      return ManhuataiStatusView(message: '还没有阅读记录');
    }
    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final record = _history[index];
        return ManhuataiComicTile(
          title: record.comicName,
          imageUrl: record.imgUrl,
          subtitle: record.chapterName,
          onTap: () => _openDetail(record.comicId),
          trailing: IconButton(
            tooltip: '删除记录',
            icon: const Icon(Icons.close),
            onPressed: () => _removeHistory(record),
          ),
        );
      },
    );
  }
}
