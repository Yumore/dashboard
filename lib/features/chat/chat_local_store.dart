import 'dart:convert';

import 'package:dashboard/features/chat/chat_conversation.dart';
import 'package:dashboard/features/chat/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline conversation persistence; remote IM can be attached behind this boundary.
class ChatLocalStore {
  static const _conversationsKey = 'content_chat_conversations';
  static String _messagesKey(String id) => 'content_chat_messages_$id';

  Future<List<ChatConversation>> conversations() async {
    final raw = (await SharedPreferences.getInstance()).getString(
      _conversationsKey,
    );
    if (raw == null) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map(
          (item) => ChatConversation.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }

  Future<ChatConversation> create(String name) async {
    final current = [...await conversations()];
    final conversation = ChatConversation(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    current.add(conversation);
    await (await SharedPreferences.getInstance()).setString(
      _conversationsKey,
      jsonEncode(current.map((item) => item.toJson()).toList()),
    );
    return conversation;
  }

  Future<List<ChatMessage>> messages(String conversationId) async {
    final raw = (await SharedPreferences.getInstance()).getString(
      _messagesKey(conversationId),
    );
    if (raw == null) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map(
          (item) => ChatMessage.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }

  Future<void> send(String conversationId, String content) async {
    final current = [...await messages(conversationId)];
    current.add(
      ChatMessage(
        idFrom: 'local',
        idTo: conversationId,
        timestamp: DateTime.now(),
        content: content,
      ),
    );
    await (await SharedPreferences.getInstance()).setString(
      _messagesKey(conversationId),
      jsonEncode(current.map((item) => item.toJson()).toList()),
    );
  }
}
