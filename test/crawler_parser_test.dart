import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:dashboard/features/crawler/crawl_html_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = CrawlHtmlParser();
  final base = Uri.parse('https://example.test/news/index.html');

  test('news presets support the current public page structures too', () {
    final it = parser.parse(
      '<div id="rank"><ul class="order sel"><li>'
      '<a href="/new">热点</a></li></ul></div>',
      CrawlConfig.presets[1],
      base,
    );
    expect(it.single.title, '热点');
    final cnr = parser.parse(
      '<div class="row1"><div class="col-l">'
      '<ul class="list-before"><li><a href="/news">央广</a></li></ul>'
      '</div></div>',
      CrawlConfig.presets[2],
      base,
    );
    expect(cnr.single.title, '央广');
  });

  test(
    'ports news selectors, resolves links and removes unsafe duplicates',
    () {
      final items = parser.parse(
        '''<div class="hot-list"><ul><li>
      <a href="../one#top"> 一 条新闻 </a><a href="../one">重复</a>
      <a href="javascript:alert(1)">脚本</a><a href="#">页内</a>
      <a href="https://user:pass@example.test/">凭据</a><a>缺失地址</a>
      <a href="//cdn.example.test/two">第二条</a>
      </li></ul></div>''',
        CrawlConfig.presets[1],
        base,
      );
      expect(items.map((item) => item.title), ['一 条新闻', '第二条']);
      expect(items.first.url.toString(), 'https://example.test/one');
      final cnr = parser.parse(
        '<div class="contentPanel"><div class="lh30">'
        '<a href="story">新闻</a></div></div>',
        CrawlConfig.presets[2],
        base,
      );
      expect(cnr.single.url.toString(), 'https://example.test/news/story');
    },
  );

  test('ports album image titles and bounds the number of results', () {
    final album = parser.parse(
      '<ul class="img"><li><a href="/album">'
      '<img alt="相册标题"></a></li></ul>',
      CrawlConfig.presets[3],
      base,
    );
    expect(album.single.title, '相册标题');
    const config = CrawlConfig(id: 'test', name: 'Test');
    final many = List.generate(
      510,
      (index) => '<a href="/$index">$index</a>',
    ).join();
    expect(parser.parse(many, config, base).length, 500);
    expect(
      () => parser.parse(
        '',
        config.edited(url: '', selector: '', encoding: 'utf-8'),
        base,
      ),
      throwsFormatException,
    );
    for (final url in [
      'file:///tmp/test',
      'https://a:b@example.test',
      '/relative',
    ]) {
      expect(
        () => config.edited(url: url, selector: 'a', encoding: 'utf-8').uri,
        throwsFormatException,
      );
    }
  });
}
