import 'package:dashboard/features/chat/chat_conversation.dart';
import 'package:dashboard/features/chat/chat_local_store.dart';
import 'package:flutter/foundation.dart';

/// Owns the local conversation list for the chat module page.
///
/// The page only renders this controller; loading, creating and refreshing
/// conversations stay in one place so the widget tree stays declarative.
class ChatHubController extends ChangeNotifier {
  ChatHubController({ChatLocalStore? store})
    : _store = store ?? ChatLocalStore();

  final ChatLocalStore _store;
  List<ChatConversation> _conversations = const [];
  bool _disposed = false;

  List<ChatConversation> get conversations => _conversations;

  Future<void> load() async {
    final conversations = await _store.conversations();
    if (_disposed) return;
    _conversations = conversations;
    notifyListeners();
  }

  Future<ChatConversation> create(String name) async {
    final conversation = await _store.create(name);
    await load();
    return conversation;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
