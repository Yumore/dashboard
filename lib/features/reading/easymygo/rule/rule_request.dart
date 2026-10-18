import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';

/// Ported from the request part of an EasyMyGo source's `SourceData`.
///
/// EasyMyGo's JS used `Http.get(url, headers, body)` style calls built from
/// strings; the port makes the request itself declarative so that the exact
/// same value can be asserted in tests. `${name}` placeholders are filled from
/// the [RuleScope] variables during [buildUri] / [buildHeaders] / [buildBody].
class RuleRequest {
  const RuleRequest({
    required this.url,
    this.method = 'GET',
    this.headers = const <String, String>{},
    this.body,
    this.encoding = 'auto',
    this.timeoutMs = 15000,
  });

  final String url;
  final String method;
  final Map<String, String> headers;
  final String? body;

  /// `auto` (sniff header/meta charset), `utf-8` or `gbk`/`gb2312`.
  final String encoding;

  final int timeoutMs;

  static final RegExp _placeholder = RegExp(r'\$\{([^}]+)\}');

  bool get isPost => method.toUpperCase() == 'POST';

  bool get isGbk =>
      encoding.toLowerCase() == 'gbk' ||
      encoding.toLowerCase() == 'gb2312' ||
      encoding.toLowerCase() == 'gb18030';

  static String interpolate(String template, Map<String, String> variables) {
    return template.replaceAllMapped(
      _placeholder,
      (match) => variables[match.group(1)!.trim()] ?? '',
    );
  }

  Uri buildUri(Map<String, String> variables) {
    final raw = interpolate(url, variables).trim();
    if (raw.isEmpty) throw const RuleException('请求地址为空');
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) {
      throw RuleException('请求地址非法: $raw');
    }
    return uri;
  }

  Map<String, String> buildHeaders(Map<String, String> variables) {
    return <String, String>{
      for (final entry in headers.entries)
        entry.key: interpolate(entry.value, variables),
    };
  }

  String? buildBody(Map<String, String> variables) {
    final template = body;
    if (template == null) return null;
    return interpolate(template, variables);
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'url': url,
    'method': method,
    'headers': headers,
    'body': body,
    'encoding': encoding,
    'timeout_ms': timeoutMs,
  };

  factory RuleRequest.fromJson(Map<String, Object?> json) => RuleRequest(
    url: '${json['url'] ?? ''}',
    method: '${json['method'] ?? 'GET'}',
    headers: <String, String>{
      for (final entry
          in (json['headers'] as Map<Object?, Object?>? ??
                  const <Object?, Object?>{})
              .entries)
        '${entry.key}': '${entry.value}',
    },
    body: json['body'] == null ? null : '${json['body']}',
    encoding: '${json['encoding'] ?? 'auto'}',
    timeoutMs: (json['timeout_ms'] as num?)?.toInt() ?? 15000,
  );
}
