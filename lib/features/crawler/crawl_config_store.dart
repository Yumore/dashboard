import 'dart:convert';

import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrawlConfigStore {
  Future<CrawlConfig> load(CrawlConfig preset) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final raw = prefs.getString('content.crawler.v1.${preset.id}');
      if (raw == null) return preset;
      final value = jsonDecode(raw);
      if (value is! Map ||
          value['url'] is! String ||
          value['selector'] is! String ||
          value['encoding'] is! String ||
          !['utf-8', 'gb2312', 'gbk'].contains(value['encoding'])) {
        return preset;
      }
      return preset.edited(
        url: value['url'],
        selector: value['selector'],
        encoding: value['encoding'],
      );
    } on FormatException {
      return preset;
    } on TypeError {
      return preset;
    }
  }

  Future<void> save(CrawlConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(
      'content.crawler.v1.${config.id}',
      jsonEncode(config.toJson()),
    )) {
      throw StateError('保存爬虫配置失败');
    }
  }
}
