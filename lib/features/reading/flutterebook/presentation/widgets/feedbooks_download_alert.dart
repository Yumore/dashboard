import 'package:dashboard/features/reading/flutterebook/data/feedbooks_download_record.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_download_service.dart';
import 'package:dashboard/features/reading/flutterebook/feedbooks_format.dart';
import 'package:flutter/material.dart';

/// 源工程 `DownloadAlert`：不可取消的下载进度弹窗。
///
/// 与源工程一致的地方：`Downloading...` + 进度条 + `$progress %` +
/// `已下载 of 总量`（都用 [FeedbooksFormat.formatBytes]，1 位小数），完成后
/// `Navigator.pop(context, size)` 把体积字符串回给调用方。
///
/// 差异（见交付说明）：
///  * 源工程把下载、写库都塞在弹窗里（permission_handler + Dio + notifier），
///    移植版把落盘交给 [FeedbooksDownloadService]，弹窗只负责进度 UI 和回调；
///  * 源工程除零时会得到 `NaN`（`received / total`，Dio 的 `totalBytes` 在
///    服务端不给长度时是 -1），这里在 total <= 0 时显示 `0`；
///  * 下载失败时源工程没有任何处理（弹窗一直转圈），这里提示并关闭。
class FeedbooksDownloadAlert extends StatefulWidget {
  const FeedbooksDownloadAlert({
    super.key,
    required this.url,
    required this.name,
    required this.image,
    required this.id,
    required this.service,
    this.onCompleted,
  });

  final String url;
  final String name;
  final String image;
  final String id;
  final FeedbooksDownloadService service;

  /// 下载成功后回调（源工程在这里 `addBook(book, id)` 写进本地库）。
  final void Function(FeedbooksDownloadRecord record)? onCompleted;

  /// 弹出下载框，返回下载体积字符串（用户中途失败时返回 null）。
  static Future<String?> show({
    required BuildContext context,
    required String url,
    required String name,
    required String image,
    required String id,
    required FeedbooksDownloadService service,
    void Function(FeedbooksDownloadRecord record)? onCompleted,
  }) {
    return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (context) => FeedbooksDownloadAlert(
        url: url,
        name: name,
        image: image,
        id: id,
        service: service,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<FeedbooksDownloadAlert> createState() => _FeedbooksDownloadAlertState();
}

class _FeedbooksDownloadAlertState extends State<FeedbooksDownloadAlert> {
  int _received = 0;
  int _total = 0;
  String _progress = '0';

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    try {
      final FeedbooksDownloadRecord record = await widget.service.download(
        url: widget.url,
        id: widget.id,
        name: widget.name,
        image: widget.image,
        onReceiveProgress: _onReceiveProgress,
      );
      if (!mounted) return;
      widget.onCompleted?.call(record);
      Navigator.of(context).pop(record.size);
    } on Exception {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Download failed. Please try again.')),
      );
    }
  }

  void _onReceiveProgress(int receivedBytes, int totalBytes) {
    if (!mounted) return;
    setState(() {
      _received = receivedBytes;
      _total = totalBytes;
      _progress = totalBytes <= 0
          ? '0'
          : (receivedBytes / totalBytes * 100).toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    return PopScope(
      canPop: false,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Downloading...',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                height: 5,
                child: LinearProgressIndicator(
                  value: double.parse(_progress) / 100.0,
                  valueColor: AlwaysStoppedAnimation<Color>(secondary),
                  backgroundColor: secondary.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 5.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '$_progress %',
                    style: const TextStyle(fontSize: 13.0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${FeedbooksFormat.formatBytes(_received, 1)} '
                    'of ${FeedbooksFormat.formatBytes(_total, 1)}',
                    style: const TextStyle(fontSize: 13.0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
