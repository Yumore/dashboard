import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_downloads_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_favorites_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_opener.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_download_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/book_details/feedbooks_book_details_page_state.dart';

/// 源工程 `BookDetailsScreen`
/// （`lib/src/features/book_details/presentation/ui/screens/book_details_screen.dart`）的宿主移植。
///
/// 页面负责：封面 / 标题 / 作者 Hero、分类标签、简介、`More from Author`、
/// 收藏按钮、分享按钮、下载/阅读按钮。
class FeedbooksBookDetailsPage extends StatefulWidget {
  const FeedbooksBookDetailsPage({
    super.key,
    required this.entry,
    this.tags,
    this.dio,
    this.downloads,
    this.favorites,
    this.downloadService,
    this.opener,
    this.shareText,
  });

  final FeedbooksEntry entry;

  /// 由列表卡片传入的 Hero tag；直接进详情页（比如深链）时自己生成一组。
  final FeedbooksBookHeroTags? tags;

  final Dio? dio;
  final FeedbooksDownloadsController? downloads;
  final FeedbooksFavoritesController? favorites;
  final FeedbooksDownloadService? downloadService;
  final FeedbooksBookOpener? opener;

  /// 分享注入点：默认走 share_plus，测试里记录文案。
  final Future<void> Function(String text)? shareText;

  static Route<void> route({
    required FeedbooksEntry entry,
    FeedbooksBookHeroTags? tags,
    Dio? dio,
    FeedbooksDownloadsController? downloads,
    FeedbooksFavoritesController? favorites,
    FeedbooksDownloadService? downloadService,
    FeedbooksBookOpener? opener,
    Future<void> Function(String text)? shareText,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => FeedbooksBookDetailsPage(
        entry: entry,
        tags: tags,
        dio: dio,
        downloads: downloads,
        favorites: favorites,
        downloadService: downloadService,
        opener: opener,
        shareText: shareText,
      ),
    );
  }

  @override
  State<FeedbooksBookDetailsPage> createState() =>
      FeedbooksBookDetailsPageState();
}
