class MovieEpisode {
  const MovieEpisode({
    required this.label,
    required this.group,
    required this.url,
  });

  final String label;
  final String group;
  final Uri url;

  factory MovieEpisode.fromJson(Map<String, dynamic> json, Uri endpoint) {
    final raw = '${json['url'] ?? ''}'.trim();
    final url = endpoint.resolve(raw);
    if (raw.isEmpty || !['http', 'https'].contains(url.scheme)) {
      throw const FormatException('影片播放地址无效');
    }
    return MovieEpisode(
      label: '${json['label'] ?? json['movieName'] ?? '正片'}',
      group: '${json['playGroup'] ?? '1'}',
      url: url,
    );
  }
}
