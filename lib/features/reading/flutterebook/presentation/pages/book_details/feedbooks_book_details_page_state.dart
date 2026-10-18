import 'package:dashboard/features/reading/flutterebook/data/feedbooks_book_details_repository.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_dio.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_download_service.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_downloads_local_data_source_impl.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_downloads_repository_impl.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_favorites_local_data_source_impl.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_favorites_repository_impl.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_book_details_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_downloads_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_favorites_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/book_details/feedbooks_book_details_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_opener.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_category_chips.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_cover_image.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_description_text.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_download_button.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_more_books_from_author.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_section_divider.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_section_title.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// [FeedbooksBookDetailsPage] 的状态。
///
/// 分享文案照抄源工程（注意源工程两个相邻字符串字面量直接拼接，`by X` 与
/// `Read/Download` 之间**没有**空格）：
/// `'${title} by ${author}Read/Download ${title} from ${link[3].href}.'`
class FeedbooksBookDetailsPageState extends State<FeedbooksBookDetailsPage> {
  late final FeedbooksBookHeroTags _tags =
      widget.tags ?? FeedbooksBookHeroTags.unique();

  Dio? _ownedDio;
  FeedbooksBookDetailsRepository? _ownedRepository;
  FeedbooksDownloadService? _ownedDownloadService;
  FeedbooksBookOpener? _ownedOpener;
  FeedbooksDownloadsLocalDataSourceImpl? _ownedDownloadsDataSource;
  FeedbooksDownloadsController? _ownedDownloadsController;
  FeedbooksFavoritesLocalDataSourceImpl? _ownedFavoritesDataSource;
  FeedbooksFavoritesController? _ownedFavoritesController;

  Dio get _dio => widget.dio ?? (_ownedDio ??= createFeedbooksDio());

  FeedbooksBookDetailsRepository get _repository =>
      _ownedRepository ??= FeedbooksBookDetailsRepository(_dio);

  FeedbooksDownloadService get _downloadService =>
      widget.downloadService ?? (_ownedDownloadService ??=
          FeedbooksDownloadService(dio: _dio));

  FeedbooksBookOpener get _opener =>
      widget.opener ?? (_ownedOpener ??= const FeedbooksBookOpener());

  FeedbooksDownloadsController get _downloads =>
      widget.downloads ??
      (_ownedDownloadsController ??= FeedbooksDownloadsController(
        repository: FeedbooksDownloadsRepositoryImpl(
          _ownedDownloadsDataSource ??= FeedbooksDownloadsLocalDataSourceImpl(),
        ),
      ));

  FeedbooksFavoritesController get _favorites =>
      widget.favorites ??
      (_ownedFavoritesController ??= FeedbooksFavoritesController(
        repository: FeedbooksFavoritesRepositoryImpl(
          _ownedFavoritesDataSource ??= FeedbooksFavoritesLocalDataSourceImpl(),
        ),
      ));

  /// 源工程 `_MoreBooksFromAuthor` 的 feed 地址（作者 uri 去掉
  /// `\&lang=en` 尾巴）。
  String get _authorUrl =>
      widget.entry.author!.uri!.t!.replaceAll(r'\&lang=en', '');

  @override
  void initState() {
    super.initState();
    _downloads.addListener(_onControllerChanged);
    _downloads.load();
    _favorites.addListener(_onControllerChanged);
    _favorites.load();
  }

  @override
  void dispose() {
    _ownedDownloadsController?.removeListener(_onControllerChanged);
    _ownedDownloadsController?.dispose();
    _ownedFavoritesController?.removeListener(_onControllerChanged);
    _ownedFavoritesController?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  FeedbooksBookDetailsController _relatedController(String url) =>
      FeedbooksBookDetailsController(repository: _repository, url: url);

  void _openBook(FeedbooksEntry entry, FeedbooksBookHeroTags tags) {
    Navigator.of(context).push(
      FeedbooksBookDetailsPage.route(entry: entry, tags: tags, dio: _dio),
    );
  }

  bool get _isFavorite => _favorites.favorites.any(
    (FeedbooksEntry element) => element.id?.t == widget.entry.id?.t,
  );

  void _toggleFavorite() {
    final String id = widget.entry.id!.t ?? '';
    if (_isFavorite) {
      _favorites.deleteBook(id);
    } else {
      _favorites.addBook(widget.entry, id);
    }
  }

  Future<void> _share() async {
    final String title = widget.entry.title!.t ?? '';
    final String author = widget.entry.author!.name!.t ?? '';
    final String text =
        '$title by $author'
        'Read/Download $title from ${widget.entry.link![3].href}.';
    final Future<void> Function(String text)? overridden = widget.shareText;
    if (overridden != null) {
      await overridden(text);
      return;
    }
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
          ),
          IconButton(onPressed: _share, icon: const Icon(Icons.share)),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final FeedbooksEntry entry = widget.entry;
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: Stack(
              children: <Widget>[
                FeedbooksCoverImage(
                  url: '${entry.link![1].href}',
                  height: 200,
                  width: 130,
                ),
                Hero(
                  tag: _tags.imgTag,
                  child: Material(
                    type: MaterialType.transparency,
                    child: FeedbooksCoverImage(
                      url: '${entry.link![1].href}',
                      height: 200,
                      width: 130,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: _tags.titleTag,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          entry.title!.t!.replaceAll(r'\', ''),
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Hero(
                      tag: _tags.authorTag,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          '${entry.author!.name!.t}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FeedbooksDownloadButton(
                entry: entry,
                downloads: _downloads,
                downloadService: _downloadService,
                opener: _opener,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: FeedbooksCategoryChips(entry: entry),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: FeedbooksSectionTitle(
            title: 'Book Description',
            emphasized: true,
          ),
        ),
        const FeedbooksSectionDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: FeedbooksDescriptionText(text: '${entry.summary!.t}'),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: FeedbooksSectionTitle(
            title: 'More from Author',
            emphasized: true,
          ),
        ),
        const FeedbooksSectionDivider(),
        FeedbooksMoreBooksFromAuthor(
          entry: entry,
          authorUrl: _authorUrl,
          controllerFactory: _relatedController,
          onTapBook: _openBook,
        ),
      ],
    );
  }
}
