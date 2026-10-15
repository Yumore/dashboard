import 'package:dashboard/features/comic/u17_chapter.dart';
import 'package:dashboard/features/comic/u17_comic.dart';
import 'package:dashboard/features/comic/u17_library_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({'host.keep': 'unchanged'}),
  );

  test(
    'favorites survive restart, deduplicate and remove only selected comic',
    () async {
      final store = U17LibraryStore();
      const first = U17Comic(id: 1, name: '漫画一', author: '作者', tags: ['奇幻']);
      const second = U17Comic(id: 2, name: '漫画二');
      await Future.wait([
        store.setFavorite(first, true),
        store.setFavorite(second, true),
      ]);
      await store.setFavorite(first, true);
      final items = await U17LibraryStore().favorites();
      expect(items.map((item) => item.id), [1, 2]);
      expect(items.first.author, '作者');
      await store.setFavorite(first, false);
      expect((await store.favorites()).single.id, 2);
      expect(
        (await SharedPreferences.getInstance()).getString('host.keep'),
        'unchanged',
      );
    },
  );

  test('history keeps each comic most recent chapter independently', () async {
    final store = U17LibraryStore();
    const first = U17Comic(id: 1, name: '漫画一');
    const second = U17Comic(id: 2, name: '漫画二');
    await store.remember(first, const U17Chapter(id: 10, name: '第一话'));
    await store.remember(second, const U17Chapter(id: 20, name: '另一漫画'));
    await store.remember(first, const U17Chapter(id: 11, name: '第二话'));
    final history = await U17LibraryStore().history();
    expect(history.map((item) => item.comic.id), [1, 2]);
    expect(history.first.chapter.id, 11);
    expect(history.last.chapter.id, 20);
  });
}
