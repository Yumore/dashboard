import 'dart:convert';

/// Legado-compatible book source (subset used by M1 engine).
class ExploreKind {
  final String title;
  final String url;

  const ExploreKind({required this.title, required this.url});
}

/// Parse Legado-style `exploreUrl` into kind list.
///
/// Supports:
/// - single URL
/// - multi-line `标题::url` / `标题&&url` / `标题=url`
/// - JSON array of `{title,url}` / `{name,url}`
List<ExploreKind> parseExploreKinds(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return const [];

  if (text.startsWith('[') || text.startsWith('{')) {
    try {
      final decoded = jsonDecode(text);
      final list = <ExploreKind>[];
      void addMap(Map m) {
        final title = (m['title'] ?? m['name'] ?? m['style'] ?? '').toString();
        final url = (m['url'] ?? m['href'] ?? m['value'] ?? '').toString();
        if (url.isEmpty) return;
        list.add(ExploreKind(
          title: title.isEmpty ? url : title,
          url: url,
        ));
      }

      if (decoded is List) {
        for (final e in decoded) {
          if (e is Map) addMap(e);
          if (e is String && e.trim().isNotEmpty) {
            list.addAll(parseExploreKinds(e));
          }
        }
        if (list.isNotEmpty) return list;
      } else if (decoded is Map) {
        addMap(decoded);
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
  }

  final lines = text
      .split(RegExp(r'[\r\n]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  final out = <ExploreKind>[];
  for (final line in lines) {
    // title::url  title&&url  title=url
    final m = RegExp(r'^(.+?)(?:::|&&|=)(.+)$').firstMatch(line);
    if (m != null) {
      final title = (m.group(1) ?? '').trim();
      final url = (m.group(2) ?? '').trim();
      if (url.isEmpty) continue;
      out.add(ExploreKind(title: title.isEmpty ? url : title, url: url));
    } else if (line.startsWith('http://') ||
        line.startsWith('https://') ||
        line.contains('{{page}}') ||
        line.contains('{page}')) {
      out.add(ExploreKind(title: '全部', url: line));
    }
  }
  if (out.isEmpty && text.isNotEmpty) {
    out.add(ExploreKind(title: '全部', url: text));
  }
  return out;
}

