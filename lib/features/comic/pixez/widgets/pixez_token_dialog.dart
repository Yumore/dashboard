import 'package:flutter/material.dart';

/// Prompts for a pixiv `access_token`.
///
/// Returns the trimmed token, or `null` when cancelled. No default/fallback
/// token exists in the app.
Future<String?> showPixezTokenDialog(BuildContext context) async {
  var value = '';
  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('输入 Pixiv 登录令牌'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'access_token',
            hintText: '粘贴 pixiv OAuth 返回的 access_token',
            border: OutlineInputBorder(),
          ),
          onChanged: (text) => value = text,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = value.trim();
              Navigator.of(dialogContext).pop(trimmed.isEmpty ? null : trimmed);
            },
            child: const Text('保存'),
          ),
        ],
      );
    },
  );
}
