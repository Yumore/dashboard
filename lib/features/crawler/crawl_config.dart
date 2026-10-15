/// Per-task configuration adapted from flutter_spider_fx's TaskConfig.
class CrawlConfig {
  const CrawlConfig({
    required this.id,
    required this.name,
    this.url = '',
    this.selector = 'a',
    this.encoding = 'utf-8',
    this.imageTitle = false,
    this.demo = false,
  });

  final String id;
  final String name;
  final String url;
  final String selector;
  final String encoding;
  final bool imageTitle;
  final bool demo;

  static const presets = [
    CrawlConfig(id: 'demo', name: '本地日志演示', demo: true),
    CrawlConfig(
      id: 'ithome',
      name: 'IT之家热点',
      url: 'https://www.ithome.com/',
      selector: '.hot-list ul li a, #rank .order.sel a',
    ),
    CrawlConfig(
      id: 'cnr',
      name: '央广新闻',
      url: 'https://news.cnr.cn/',
      selector: '.contentPanel .lh30 a, .row1 .col-l .list-before a',
      encoding: 'gb2312',
    ),
    // The original LiGui adapter extracts img.alt and a.href from ul.img li.
    // Preserve its source URL, but only fetch after an explicit user action.
    CrawlConfig(
      id: 'album',
      name: '相册链接',
      url: 'https://www.meitulu.com/t/ligui/',
      selector: 'ul.img li',
      encoding: 'gb2312',
      imageTitle: true,
    ),
  ];

  CrawlConfig edited({
    required String url,
    required String selector,
    required String encoding,
  }) => CrawlConfig(
    id: id,
    name: name,
    url: url.trim(),
    selector: selector.trim(),
    encoding: encoding,
    imageTitle: imageTitle,
    demo: demo,
  );

  Uri get uri {
    final value = Uri.tryParse(url);
    if (value == null ||
        !['http', 'https'].contains(value.scheme) ||
        value.host.isEmpty ||
        value.userInfo.isNotEmpty) {
      throw const FormatException('请输入不含账号密码的 HTTP/HTTPS 网页地址');
    }
    return value;
  }

  Map<String, Object> toJson() => {
    'url': url,
    'selector': selector,
    'encoding': encoding,
  };
}
