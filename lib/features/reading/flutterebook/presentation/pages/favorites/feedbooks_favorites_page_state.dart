import 'package:dashboard/features/reading/flutterebook/data/feedbooks_favorites_local_data_source_impl.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_favorites_repository_impl.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_favorites_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/book_details/feedbooks_book_details_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/favorites/feedbooks_favorites_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_item.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_empty_view.dart';
import 'package:flutter/material.dart';

/// [FeedbooksFavoritesPage] 的状态。
///
/// 源工程这一段的写法有个 bug：`if (favorites.isEmpty) const EmptyView();`
/// 少写了 `return`，空态永远不会显示。移植版按原意补上 `return`
/// （见交付说明的「刻意偏差」）。
class FeedbooksFavoritesPageState extends State<FeedbooksFavoritesPage> {
  FeedbooksFavoritesLocalDataSourceImpl? _ownedDataSource;
  FeedbooksFavoritesController? _ownedFavorites;

  FeedbooksFavoritesController get _favorites =>
      widget.favorites ??
      (_ownedFavorites ??= FeedbooksFavoritesController(
        repository: FeedbooksFavoritesRepositoryImpl(
          _ownedDataSource ??= FeedbooksFavoritesLocalDataSourceImpl(),
        ),
      ));

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_onControllerChanged);
    _favorites.load();
  }

  @override
  void dispose() {
    _ownedFavorites?.removeListener(_onControllerChanged);
    _ownedFavorites?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openBook(FeedbooksEntry entry, FeedbooksBookHeroTags tags) {
    Navigator.of(context).push(
      FeedbooksBookDetailsPage.route(
        entry: entry,
        tags: tags,
        dio: widget.dio,
        favorites: _favorites,
        downloadService: widget.downloadService,
        opener: widget.opener,
        shareText: widget.shareText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<FeedbooksEntry> favorites = _favorites.favorites;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Favorites'),
      ),
      body: favorites.isEmpty
          ? const FeedbooksEmptyView()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Wrap(
                children: favorites
                    .map(
                      (FeedbooksEntry entry) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 5.0,
                        ),
                        child: FeedbooksBookItem(
                          img: entry.link![1].href!,
                          title: entry.title!.t!,
                          entry: entry,
                          onTap: (FeedbooksBookHeroTags tags) =>
                              _openBook(entry, tags),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}
