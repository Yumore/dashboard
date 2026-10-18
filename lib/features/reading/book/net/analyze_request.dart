

class AnalyzeRequest {
  final String url;
  final String method;
  final Map<String, String> headers;
  final dynamic body;
  final String charset;

  AnalyzeRequest({
    required this.url,
    this.method = 'GET',
    Map<String, String>? headers,
    this.body,
    this.charset = 'utf-8',
  }) : headers = headers ?? {};
}

/// Build request from Legado-style searchUrl / absolute url + source header.
