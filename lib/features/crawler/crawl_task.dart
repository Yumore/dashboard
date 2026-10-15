import 'dart:async';

import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:dashboard/features/crawler/crawl_html_parser.dart';
import 'package:dashboard/features/crawler/crawl_http_client.dart';
import 'package:dashboard/features/crawler/crawl_item.dart';
import 'package:dashboard/features/crawler/crawl_log.dart';
import 'package:dashboard/features/crawler/crawl_page_data.dart';
import 'package:dashboard/features/crawler/crawl_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

typedef CrawlFetcher =
    Future<CrawlPageData> Function(CrawlConfig config, CancelToken token);

/// Owns only the task lifecycle, with cancellation and a pause commit barrier.
class CrawlTask extends ChangeNotifier {
  CrawlTask(this.config, {CrawlFetcher? fetch}) {
    if (fetch == null) _client = CrawlHttpClient();
    _fetch = fetch ?? _client!.fetch;
  }

  CrawlConfig config;
  CrawlState state = CrawlState.idle;
  final _logs = <CrawlLog>[];
  final _items = <CrawlItem>[];
  CrawlHttpClient? _client;
  late final CrawlFetcher _fetch;
  CancelToken? _token;
  Completer<void>? _paused;
  int _generation = 0;
  bool _disposed = false;

  List<CrawlLog> get logs => List.unmodifiable(_logs);
  List<CrawlItem> get items => List.unmodifiable(_items);
  bool get active => state == CrawlState.running || state == CrawlState.paused;

  void _log(String level, String content) {
    if (_logs.length == 1024) _logs.removeAt(0);
    _logs.add(CrawlLog(level, content));
    notifyListeners();
  }

  bool _current(int generation) => !_disposed && generation == _generation;

  Future<bool> _checkpoint(int generation) async {
    while (_current(generation) && state == CrawlState.paused) {
      await _paused!.future;
    }
    return _current(generation);
  }

  Future<void> start() async {
    if (_disposed || active) return;
    final config = this.config;
    final generation = ++_generation;
    final token = _token = CancelToken();
    state = CrawlState.running;
    _items.clear();
    _log('info', '开始：${config.name}');
    try {
      if (config.demo) {
        for (var index = 0; index < 10; index++) {
          if (!await _checkpoint(generation)) return;
          for (final level in [
            'verbose',
            'debug',
            'info',
            'warning',
            'error',
          ]) {
            if (!_current(generation)) return;
            _log(level, '本地日志演示 ${index + 1}');
          }
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      } else {
        final page = await _fetch(
          config,
          token,
        ).timeout(const Duration(seconds: 30));
        if (!await _checkpoint(generation)) return;
        _items.addAll(CrawlHtmlParser().parse(page.html, config, page.uri));
        _log(
          'info',
          _items.isEmpty ? '未匹配链接，请检查网页结构和选择器' : '提取 ${_items.length} 条链接',
        );
      }
      if (!await _checkpoint(generation)) return;
      state = CrawlState.completed;
      _log('info', '完成');
    } catch (error) {
      if (!_current(generation)) return;
      token.cancel('request failed');
      if (!await _checkpoint(generation)) return;
      state = CrawlState.failed;
      _log('error', '任务失败：$error');
    }
  }

  void pause() {
    if (_disposed || state != CrawlState.running) return;
    _paused = Completer<void>();
    state = CrawlState.paused;
    _log('info', '暂停（在途请求可结束，但结果待继续后提交）');
  }

  void _releasePause() {
    _paused?.complete();
    _paused = null;
  }

  void resume() {
    if (_disposed || state != CrawlState.paused) return;
    state = CrawlState.running;
    _releasePause();
    _log('info', '继续');
  }

  void stop() {
    if (_disposed || !active) return;
    _generation++;
    _token?.cancel('stopped by user');
    _releasePause();
    state = CrawlState.stopped;
    _log('info', '已停止');
  }

  void clearLogs() {
    if (_disposed) return;
    _logs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _token?.cancel('disposed');
    _releasePause();
    _client?.dispose();
    super.dispose();
  }
}
