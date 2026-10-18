import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_tile.dart';
import 'package:dashboard/features/comic/hakacomic/haka_doc.dart';
import 'package:dashboard/features/comic/hakacomic/haka_favorite_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_local_folder.dart';
import 'package:dashboard/features/comic/hakacomic/haka_local_favorites_page.dart';

/// State of [HakaLocalFavoritesPage].
class HakaLocalFavoritesPageState extends State<HakaLocalFavoritesPage> {
  List<HakaLocalFolder> _folders = const [];
  String _selected = HakaFavoriteStore.defaultFolderName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final folders = await widget.favoriteStore.folders();
    if (!mounted) return;
    setState(() {
      _folders = folders;
      _loading = false;
      if (!folders.any((folder) => folder.name == _selected)) {
        _selected = folders.isEmpty
            ? HakaFavoriteStore.defaultFolderName
            : folders.first.name;
      }
    });
  }

  HakaLocalFolder? get _current {
    for (final folder in _folders) {
      if (folder.name == _selected) return folder;
    }
    return null;
  }

  Future<void> _createFolder() async {
    final name = await _promptFolderName('新建收藏夹');
    if (name == null || name.isEmpty) return;
    await widget.favoriteStore.createFolder(name);
    await _reload();
  }

  Future<void> _renameFolder() async {
    final name = await _promptFolderName('重命名收藏夹', initial: _selected);
    if (name == null || name.isEmpty) return;
    await widget.favoriteStore.renameFolder(_selected, name);
    if (!mounted) return;
    setState(() => _selected = name);
    await _reload();
  }

  Future<void> _deleteFolder() async {
    await widget.favoriteStore.deleteFolder(_selected);
    if (!mounted) return;
    setState(() => _selected = HakaFavoriteStore.defaultFolderName);
    await _reload();
  }

  Future<String?> _promptFolderName(String title, {String? initial}) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '收藏夹名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final folder = _current;
    final comics = folder?.comics ?? const <Map<String, dynamic>>[];
    final isDefault = _selected == HakaFavoriteStore.defaultFolderName;
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              for (final item in _folders)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${item.name} (${item.comics.length})'),
                    selected: item.name == _selected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selected = item.name);
                    },
                  ),
                ),
              IconButton(
                tooltip: '新建收藏夹',
                onPressed: _createFolder,
                icon: const Icon(Icons.create_new_folder_outlined),
              ),
              IconButton(
                tooltip: '重命名',
                onPressed: isDefault ? null : _renameFolder,
                icon: const Icon(Icons.drive_file_rename_outline),
              ),
              IconButton(
                tooltip: '删除收藏夹',
                onPressed: isDefault ? null : _deleteFolder,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: comics.isEmpty
              ? const Center(child: Text('该收藏夹还没有漫画'))
              : ListView.builder(
                  itemCount: comics.length,
                  itemBuilder: (context, index) {
                    final doc = HakaDoc.fromJson(comics[index]);
                    return HakaComicTile(
                      comic: doc,
                      onTap: () => widget.onOpenComic(doc.uid),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
