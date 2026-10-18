import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_downloads_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_opener.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/downloads/feedbooks_downloads_page_state.dart';

/// 源工程 `DownloadsScreen`
/// （`lib/src/features/downloads/presentation/ui/screens/download_screen.dart`）的宿主移植。
///
/// 列表项 = 已下载的 EPUB；左滑删除；点击用外部阅读器打开。
class FeedbooksDownloadsPage extends StatefulWidget {
  const FeedbooksDownloadsPage({
    super.key,
    this.downloads,
    this.opener,
  });

  /// 不传时页面自己创建并负责 dispose。
  final FeedbooksDownloadsController? downloads;
  final FeedbooksBookOpener? opener;

  static Route<void> route({
    FeedbooksDownloadsController? downloads,
    FeedbooksBookOpener? opener,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => FeedbooksDownloadsPage(
        downloads: downloads,
        opener: opener,
      ),
    );
  }

  @override
  State<FeedbooksDownloadsPage> createState() => FeedbooksDownloadsPageState();
}
