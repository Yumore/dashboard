import 'package:dashboard/features/reading/flutterebook/data/feedbooks_download_record.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_downloads_local_data_source_impl.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_downloads_repository_impl.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_downloads_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/downloads/feedbooks_downloads_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_opener.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_cover_image.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_dismissible_background.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_empty_view.dart';
import 'package:flutter/material.dart';

/// [FeedbooksDownloadsPage] 的状态。
///
/// 行的排版与源工程一致：70x70 封面 + 书名 + 分隔线 + `COMPLETED` / 体积；
/// 左滑（`DismissDirection.endToStart`）删除记录。
class FeedbooksDownloadsPageState extends State<FeedbooksDownloadsPage> {
  FeedbooksDownloadsLocalDataSourceImpl? _ownedDataSource;
  FeedbooksDownloadsController? _ownedDownloads;
  FeedbooksBookOpener? _ownedOpener;

  FeedbooksDownloadsController get _downloads =>
      widget.downloads ??
      (_ownedDownloads ??= FeedbooksDownloadsController(
        repository: FeedbooksDownloadsRepositoryImpl(
          _ownedDataSource ??= FeedbooksDownloadsLocalDataSourceImpl(),
        ),
      ));

  FeedbooksBookOpener get _opener =>
      widget.opener ?? (_ownedOpener ??= const FeedbooksBookOpener());

  @override
  void initState() {
    super.initState();
    _downloads.addListener(_onControllerChanged);
    _downloads.load();
  }

  @override
  void dispose() {
    _ownedDownloads?.removeListener(_onControllerChanged);
    _ownedDownloads?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// 源工程 `openBook`：文件在就用阅读器打开，不在就提示并删除失效记录。
  ///
  /// 源工程跳的是 vendored Readium 的 `EpubScreen`，本任务不移植阅读器，
  /// 改为交给系统外部应用打开（详见交付说明）。
  Future<void> _openBook(FeedbooksDownloadRecord record) async {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    if (!await _opener.exists(record.path)) {
      await _downloads.deleteBook(record.id);
      messenger?.showSnackBar(
        const SnackBar(content: Text(FeedbooksBookOpener.missingFileMessage)),
      );
      return;
    }
    final bool opened = await _opener.openFile(record.path);
    if (!opened) {
      messenger?.showSnackBar(
        const SnackBar(content: Text(FeedbooksBookOpener.openFailedMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<FeedbooksDownloadRecord> records = _downloads.records;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Downloads'),
      ),
      body: records.isEmpty
          ? const FeedbooksEmptyView()
          : ListView.separated(
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 5),
              itemBuilder: (BuildContext context, int index) {
                return _DownloadRow(
                  record: records[index],
                  onTap: () => _openBook(records[index]),
                  onDismissed: () => _downloads.deleteBook(records[index].id),
                );
              },
            ),
    );
  }
}

/// 单条下载记录（源工程 `download_screen.dart` 的匿名 ListView 子项）。
class _DownloadRow extends StatelessWidget {
  const _DownloadRow({
    required this.record,
    required this.onTap,
    required this.onDismissed,
  });

  final FeedbooksDownloadRecord record;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey(record.id),
      direction: DismissDirection.endToStart,
      background: const FeedbooksDismissibleBackground(),
      onDismissed: (_) => onDismissed(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            children: <Widget>[
              FeedbooksCoverImage(
                url: record.image,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      record.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'COMPLETED',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        Text(
                          record.size,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
