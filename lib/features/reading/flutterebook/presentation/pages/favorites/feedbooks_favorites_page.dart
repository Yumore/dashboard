import 'package:dashboard/features/reading/flutterebook/data/feedbooks_download_service.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_favorites_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_opener.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/favorites/feedbooks_favorites_page_state.dart';

/// 源工程 `FavoritesScreen`
/// （`lib/src/features/favorites/presentation/ui/screens/favorites_screen.dart`）的宿主移植。
///
/// 网格是 `Wrap` + `BookItem`，点击进详情页。
class FeedbooksFavoritesPage extends StatefulWidget {
  const FeedbooksFavoritesPage({
    super.key,
    this.favorites,
    this.dio,
    this.opener,
    this.downloadService,
    this.shareText,
  });

  /// 不传时页面自己创建并负责 dispose。
  final FeedbooksFavoritesController? favorites;
  final Dio? dio;

  /// 透传给详情页的注入点（详情页「阅读」按钮 / 分享文案）。
  final FeedbooksBookOpener? opener;
  final FeedbooksDownloadService? downloadService;
  final Future<void> Function(String text)? shareText;

  static Route<void> route({
    FeedbooksFavoritesController? favorites,
    Dio? dio,
    FeedbooksBookOpener? opener,
    FeedbooksDownloadService? downloadService,
    Future<void> Function(String text)? shareText,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => FeedbooksFavoritesPage(
        favorites: favorites,
        dio: dio,
        opener: opener,
        downloadService: downloadService,
        shareText: shareText,
      ),
    );
  }

  @override
  State<FeedbooksFavoritesPage> createState() => FeedbooksFavoritesPageState();
}
