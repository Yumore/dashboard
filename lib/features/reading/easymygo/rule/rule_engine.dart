import 'dart:convert';

import 'package:dashboard/features/reading/easymygo/rule/json_path_action.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_endpoint.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_list_spec.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_result.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_scope.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

/// The HTTP + rule-evaluation engine.
///
/// Replaces the `flutter_js` runtime EasyMyGo used to evaluate a source's JS:
/// it performs the endpoint request, decodes the body with the declared charset
/// and evaluates the endpoint's field/list rules over it. A client can be
/// injected so the whole engine is testable without a network.
class RuleEngine {
  RuleEngine({http.Client? client, this.timeout = const Duration(milliseconds: 15000)})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  Future<RuleResult> execute(RuleEndpoint endpoint, RuleScope scope) async {
    final request = endpoint.request;
    final uri = request.buildUri(scope.variables);
    final headers = request.buildHeaders(scope.variables);
    final body = request.buildBody(scope.variables);
    final http.Response response;
    try {
      final outbound = http.Request(request.method.toUpperCase(), uri);
      outbound.headers.addAll(headers);
      if (body != null && body.isNotEmpty) {
        if (request.isGbk) {
          outbound.bodyBytes = gbk.encode(body);
          outbound.headers.putIfAbsent(
            'content-type',
            () => 'application/x-www-form-urlencoded; charset=gbk',
          );
        } else {
          outbound.body = body;
        }
      }
      final streamed = await _client.send(outbound).timeout(timeout);
      response = await http.Response.fromStream(streamed);
    } on RuleException {
      rethrow;
    } catch (error) {
      throw RuleException('网络请求失败: $error');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RuleException('请求失败: HTTP ${response.statusCode}');
    }
    final text = decodeResponseBody(response, request.encoding);
    if (text.trim().isEmpty) {
      throw RuleException('${endpoint.business} 响应内容为空');
    }
    scope.set('body', text);
    scope.set('url', uri.toString());

    final values = <String, String>{};
    for (final field in endpoint.fields) {
      values[field.name] = field.evaluate(scope);
    }
    final lists = <String, List<Map<String, String>>>{};
    for (final spec in endpoint.lists) {
      lists[spec.name] = _evaluateList(spec, scope, text);
    }
    if (values.values.every((e) => e.isEmpty) &&
        lists.values.every((e) => e.isEmpty)) {
      throw RuleException('${endpoint.business} 未解析出任何数据');
    }
    return RuleResult(values: values, lists: lists);
  }

  List<Map<String, String>> _evaluateList(
    RuleListSpec spec,
    RuleScope scope,
    String body,
  ) {
    final items = <String>[];
    if (spec.mode == RuleListMode.json) {
      final Object? decoded;
      try {
        decoded = jsonDecode(body);
      } on FormatException catch (error) {
        throw RuleException('列表 ${spec.name} 的响应不是合法 JSON: ${error.message}');
      }
      for (final match in JsonPathAction.queryPath(decoded, spec.itemSelector)) {
        items.add(jsonEncode(match));
      }
    } else {
      if (spec.itemSelector.isEmpty) {
        throw RuleException('列表 ${spec.name} 缺少 item_selector');
      }
      final document = html_parser.parse(body);
      for (final element in document.querySelectorAll(spec.itemSelector)) {
        items.add(element.outerHtml);
      }
    }
    final rows = <Map<String, String>>[];
    for (final item in items) {
      scope.set('item', item);
      final row = <String, String>{};
      for (final field in spec.fields) {
        row[field.name] = field.evaluate(scope);
      }
      rows.add(row);
    }
    scope.variables.remove('item');
    return rows;
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}

/// Decodes [response] honouring the source's declared encoding.
///
/// Order: explicit `gbk`/`utf-8`, then the `content-type` charset, then a
/// `<meta charset>` sniff on the first 4 KiB, then UTF-8. EasyMyGo relied on the
/// platform webview for this; the host has `enough_convert` available, so GBK
/// sources keep working.
String decodeResponseBody(http.Response response, String encoding) {
  final bytes = response.bodyBytes;
  final declared = encoding.toLowerCase();
  if (_isGbk(declared)) return gbk.decode(bytes);
  if (declared == 'utf-8' || declared == 'utf8') {
    return utf8.decode(bytes, allowMalformed: true);
  }
  final headerCharset = _charsetOf(response.headers['content-type'] ?? '');
  if (headerCharset != null) {
    if (_isGbk(headerCharset)) return gbk.decode(bytes);
    return utf8.decode(bytes, allowMalformed: true);
  }
  final head = utf8.decode(bytes.take(4096).toList(), allowMalformed: true);
  final metaCharset = RegExp(
    r'''charset\s*=\s*["']?([\w-]+)''',
    caseSensitive: false,
  ).firstMatch(head)?.group(1);
  if (metaCharset != null && _isGbk(metaCharset)) return gbk.decode(bytes);
  return utf8.decode(bytes, allowMalformed: true);
}

bool _isGbk(String name) =>
    name == 'gbk' || name == 'gb2312' || name == 'gb18030';

String? _charsetOf(String contentType) {
  final match = RegExp(
    r'charset\s*=\s*([\w-]+)',
    caseSensitive: false,
  ).firstMatch(contentType);
  return match?.group(1)?.toLowerCase();
}
