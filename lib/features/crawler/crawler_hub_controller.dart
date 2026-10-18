import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:dashboard/features/crawler/crawl_config_store.dart';
import 'package:dashboard/features/crawler/crawl_task.dart';
import 'package:flutter/foundation.dart';

/// Owns the configured crawl sources and their live task state.
class CrawlerHubController extends ChangeNotifier {
  CrawlerHubController({CrawlConfigStore? store})
    : _store = store ?? CrawlConfigStore();

  final CrawlConfigStore _store;
  final List<CrawlTask> _tasks = [];
  String? _error;
  bool _loading = true;
  bool _disposed = false;

  List<CrawlTask> get tasks => _tasks;
  String? get error => _error;
  bool get loading => _loading;
  CrawlConfigStore get store => _store;

  Future<void> load() async {
    try {
      final configs = await Future.wait(CrawlConfig.presets.map(_store.load));
      if (_disposed) return;
      for (final task in _tasks) {
        task.dispose();
      }
      _tasks.clear();
      _tasks.addAll(configs.map((config) => CrawlTask(config)));
      _loading = false;
      notifyListeners();
    } catch (error) {
      if (_disposed) return;
      _error = '$error';
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final task in _tasks) {
      task.dispose();
    }
    super.dispose();
  }
}
