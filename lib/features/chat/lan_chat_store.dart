import 'dart:convert';

import 'package:dashboard/features/chat/lan_chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanChatStore {
  static const _settingsKey = 'content.lan_chat.settings';

  String _key(String endpoint, String user, String peer) =>
      'content.lan_chat.messages.${jsonEncode([endpoint, user, peer])}';

  Future<Map<String, String>> settings() async {
    final raw = (await SharedPreferences.getInstance()).getString(_settingsKey);
    if (raw == null) return {};
    final value = jsonDecode(raw);
    if (value is! Map) return {};
    return value.map((key, value) => MapEntry('$key', '$value'));
  }

  Future<void> saveSettings(String endpoint, String device) async {
    await (await SharedPreferences.getInstance()).setString(
      _settingsKey,
      jsonEncode({'endpoint': endpoint, 'device': device}),
    );
  }

  Future<List<LanChatMessage>> load(
    String endpoint,
    String user,
    String peer,
  ) async {
    final values =
        (await SharedPreferences.getInstance()).getStringList(
          _key(endpoint, user, peer),
        ) ??
        [];
    return values
        .map(
          (raw) =>
              LanChatMessage.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> save(
    String endpoint,
    String user,
    String peer,
    List<LanChatMessage> messages,
  ) async {
    final retained = messages.length > 100
        ? messages.sublist(messages.length - 100)
        : messages;
    await (await SharedPreferences.getInstance()).setStringList(
      _key(endpoint, user, peer),
      retained.map((message) => message.encode()).toList(),
    );
  }

  Future<void> clear(String endpoint, String user, String peer) async {
    await (await SharedPreferences.getInstance()).remove(
      _key(endpoint, user, peer),
    );
  }
}
