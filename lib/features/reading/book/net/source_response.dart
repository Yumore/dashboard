

class SourceResponse {
  final String url;
  final String body;
  final String contentType;
  final int statusCode;

  SourceResponse({
    required this.url,
    required this.body,
    this.contentType = 'text/html',
    this.statusCode = 200,
  });

  bool get isJson =>
      contentType.contains('json') ||
      body.trimLeft().startsWith('{') ||
      body.trimLeft().startsWith('[');
}
