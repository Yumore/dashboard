class MediaStreamSource {
  const MediaStreamSource({
    required this.label,
    required this.url,
    this.headers = const {},
  });

  final String label;
  final Uri url;
  final Map<String, String> headers;
}
