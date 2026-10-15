import 'dart:convert';
import 'dart:io';

import 'package:dashboard/features/crawler/crawl_task.dart';
import 'package:path_provider/path_provider.dart';

/// Produces task-scoped JSON snapshots without the source app's storage permission.
class CrawlExporter {
  CrawlExporter({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directory;

  String encode(CrawlTask task, String kind) {
    final Object value;
    switch (kind) {
      case 'config':
        value = task.config.toJson();
      case 'logs':
        value = task.logs.map((log) => log.toJson()).toList();
      case 'results':
        value = task.items.map((item) => item.toJson()).toList();
      default:
        throw ArgumentError.value(kind, 'kind', 'Unknown export type');
    }
    return const JsonEncoder.withIndent('  ').convert(value);
  }

  Future<File> save(CrawlTask task, String kind) async {
    // Capture before awaiting so a subsequent run cannot change this snapshot.
    final content = encode(task, kind);
    final taskId = task.config.id;
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(taskId)) {
      throw const FormatException('无效任务标识');
    }
    final root = await _directory();
    final folder = Directory('${root.path}/content_crawler/$taskId');
    await folder.create(recursive: true);
    return File(
      '${folder.path}/${kind}_${DateTime.now().microsecondsSinceEpoch}.json',
    ).writeAsString(content, flush: true);
  }
}
