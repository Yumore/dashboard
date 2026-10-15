class CrawlLog {
  CrawlLog(this.level, this.content) : time = DateTime.now();

  final String level;
  final String content;
  final DateTime time;

  Map<String, String> toJson() => {
    'level': level,
    'content': content,
    'dateTime': time.toIso8601String(),
  };
}
