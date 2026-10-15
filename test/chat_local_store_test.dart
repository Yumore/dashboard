import 'package:dashboard/features/chat/chat_local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'local conversation and message survive a store instance change',
    () async {
      SharedPreferences.setMockInitialValues({});
      final first = ChatLocalStore();
      final conversation = await first.create('阅读讨论');
      await first.send(conversation.id, '你好');

      final second = ChatLocalStore();
      expect((await second.conversations()).single.name, '阅读讨论');
      expect((await second.messages(conversation.id)).single.content, '你好');
    },
  );
}
