import 'dart:convert';

import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_scope.dart';
import 'package:dashboard/features/reading/easymygo/rule/source_action.dart';

/// JSONPath-style extractor for the JSON APIs many EasyMyGo sources talk to.
///
/// EasyMyGo sources evaluated JSON inside JS; the port provides this dedicated
/// action instead, with the same constructor shape
/// (`JsonPath(content, path).text()`).
///
/// Supported path grammar: `$`, `.key`, `['key']`, `["key"]`, `[0]`, `[*]`,
/// `.*`, `..key` (recursive descent).
class JsonPathAction extends SourceAction {
  const JsonPathAction();

  @override
  String get clazz => 'JsonPath';

  @override
  int get constructorArgsCount => 2;

  @override
  List<String> get funcNames => const <String>['text', 'all', 'json'];

  @override
  String execute(
    RuleScope scope,
    String funcName,
    List<String> constructorArgs,
    List<String> args,
  ) {
    final content = constructorArgs.isNotEmpty ? constructorArgs.first : '';
    final path = constructorArgs.length > 1 ? constructorArgs[1] : r'$';
    if (content.isEmpty) {
      throw const RuleException('JsonPath 内容为空');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException catch (e) {
      throw RuleException('JsonPath 输入不是合法 JSON: ${e.message}');
    }
    final matches = queryPath(decoded, path);
    switch (funcName) {
      case 'text':
        return matches.isEmpty ? '' : asString(matches.first);
      case 'all':
        return jsonEncode(matches.map(asString).toList());
      case 'json':
        return matches.isEmpty ? 'null' : jsonEncode(matches.first);
    }
    throw RuleException('JsonPath 不支持 $funcName');
  }

  /// Evaluates [path] against a decoded JSON [root] and returns every match.
  static List<Object?> queryPath(Object? root, String path) {
    final source = path.trim();
    var current = <Object?>[root];
    var index = source.startsWith(r'$') ? 1 : 0;
    while (index < source.length) {
      final char = source[index];
      if (char == '.') {
        if (index + 1 < source.length && source[index + 1] == '.') {
          final match = RegExp(
            r'^\.\.\s*([A-Za-z_$][-A-Za-z0-9_$]*)',
          ).firstMatch(source.substring(index));
          if (match == null) break;
          final name = match.group(1)!;
          final collected = <Object?>[];
          for (final node in current) {
            _recursive(node, name, collected);
          }
          current = collected;
          index += match.end;
        } else if (index + 1 < source.length && source[index + 1] == '*') {
          final collected = <Object?>[];
          for (final node in current) {
            if (node is Map) {
              collected.addAll(node.values);
            } else if (node is List) {
              collected.addAll(node);
            }
          }
          current = collected;
          index += 2;
        } else {
          final match = RegExp(
            r'^\.\s*([A-Za-z_$][-A-Za-z0-9_$]*)',
          ).firstMatch(source.substring(index));
          if (match == null) break;
          current = _pluck(current, match.group(1)!);
          index += match.end;
        }
      } else if (char == '[') {
        final end = source.indexOf(']', index);
        if (end < 0) break;
        final raw = source.substring(index + 1, end).trim();
        if (raw == '*') {
          final collected = <Object?>[];
          for (final node in current) {
            if (node is Map) {
              collected.addAll(node.values);
            } else if (node is List) {
              collected.addAll(node);
            }
          }
          current = collected;
        } else if (raw.startsWith("'") || raw.startsWith('"')) {
          final name = raw.substring(1, raw.length - 1);
          current = _pluck(current, name);
        } else {
          final position = int.tryParse(raw);
          if (position == null) {
            current = _pluck(current, raw);
          } else {
            current = <Object?>[
              for (final node in current)
                if (node is List && position < node.length) node[position],
            ];
          }
        }
        index = end + 1;
      } else {
        index++;
      }
    }
    return current;
  }

  /// Renders a JSON scalar (or a re-encoded container) as a string.
  static String asString(Object? value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return jsonEncode(value);
  }

  static List<Object?> _pluck(List<Object?> nodes, String name) {
    final collected = <Object?>[];
    for (final node in nodes) {
      if (node is Map) {
        if (node.containsKey(name)) collected.add(node[name]);
      } else if (node is List) {
        collected.addAll(_pluck(node, name));
      }
    }
    return collected;
  }

  static void _recursive(Object? node, String name, List<Object?> out) {
    if (node is Map) {
      if (node.containsKey(name)) out.add(node[name]);
      for (final value in node.values) {
        _recursive(value, name, out);
      }
    } else if (node is List) {
      for (final value in node) {
        _recursive(value, name, out);
      }
    }
  }
}
