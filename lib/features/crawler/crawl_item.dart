class CrawlItem {
  const CrawlItem({required this.title, required this.url});

  final String title;
  final Uri url;

  Map<String, String> toJson() => {'title': title, 'link': url.toString()};
}
