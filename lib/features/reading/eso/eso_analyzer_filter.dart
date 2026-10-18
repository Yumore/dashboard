import 'package:dashboard/features/reading/eso/eso_analyzer.dart';

/// `@filter:` 规则解析器（移植 eso `lib/api/analyzer_filter.dart` 的 URL 归一化与直接匹配部分）。
///
/// 规则形如 `正则@@嗅探时长`（时长缺省 10 秒）。原实现除了直接匹配，还会用无头
/// WebView 嗅探播放地址（`flutter_inappwebview` / 自带 `flutter_webview` 模块）。
/// 宿主既没有 JS 规则引擎也没有这套嗅探插件，因此这里保留：
///
/// * 相对协议 `//host/path` 按书源 host 的协议补全
/// * 根路径 `/path` 拼上书源 host
/// * 当前 URL 命中正则时返回 `[{url: ...}]`（与源实现相同的返回结构）
///
/// 嗅探分支被有意丢弃（见交付说明），未命中时返回空列表。
class EsoAnalyzerFilter implements EsoAnalyzer {
  EsoAnalyzerFilter({this.host = ''});

  final String host;

  String _url = '';

  @override
  EsoAnalyzerFilter parse(dynamic content) {
    var url = '';
    if (content is List) {
      for (final item in content) {
        final text = '$item'.trim();
        if (text.isNotEmpty) {
          url = text;
          break;
        }
      }
      if (url.isEmpty) url = host;
    } else if (content is Map) {
      url = '${content["url"]}';
    } else {
      url = '$content'.trim();
    }
    if (url.startsWith('//')) {
      url = host.startsWith('https') ? 'https:$url' : 'http:$url';
    } else if (url.startsWith('/')) {
      url = '$host$url';
    }
    _url = url;
    return this;
  }

  /// 命中时返回 `[{url: 地址}]`，与源实现保持一致（供播放层取流地址）。
  @override
  List<dynamic> getStringList(String rule) {
    final r = rule.split('@@');
    if (r[0].isEmpty) return <dynamic>[];
    if (!_url.contains(RegExp(r[0]))) return <dynamic>[];
    return <dynamic>[
      <String, dynamic>{'url': _url},
    ];
  }

  @override
  String getString(String rule) {
    final list = getStringList(rule);
    if (list.isEmpty) return '';
    return '${(list.first as Map)['url']}';
  }

  @override
  List<dynamic> getElements(String rule) => getStringList(rule);
}
