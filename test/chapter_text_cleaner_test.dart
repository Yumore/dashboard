import 'package:dashboard/features/reading/chapter_text_cleaner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('removes non-content nodes and applies source replace rules', () {
    const cleaner = ChapterTextCleaner();
    const html =
        '<body><p>第一段<br>广告词</p><script>evil()</script><p>123</p><p>第二段</p></body>';
    final text = cleaner.clean(html, replaceRule: '广告词##正文');
    expect(text, contains('正文'));
    expect(text, contains('第二段'));
    expect(text, isNot(contains('evil')));
    expect(text, isNot(contains('123')));
  });
}
