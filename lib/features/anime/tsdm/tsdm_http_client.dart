import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/anime/tsdm/tsdm_api_urls.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_cookie_store.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_exception.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_base.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_config.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_str_bytes.dart';
import 'package:http/http.dart' as http;

/// The tsdm forum http client.
///
/// Ported from `tsdm_client/lib/shared/providers/net_client_provider/net_client_provider.dart`.
/// The source built a `Dio` instance with a cookie manager and interceptors;
/// the host can only rely on `package:http`, so the same transport behavior is
/// reimplemented here:
///
/// * a cookie header built from an injected [TsdmCookieStore], updated from
///   every `set-cookie` response header,
/// * the source's force desktop layout interceptor (append `mobile=no` for
///   requests to the forum hosts only),
/// * the source's gzip encoding checker (non GET requests and `goto=findpost`
///   requests ask for `deflate, br` so the server does not gzip the response),
/// * `deflate, br` (instead of gzip) accept encoding for images,
/// * `HttpRequestFailedException` on any non 200 status code.
class TsdmHttpClient {
  /// Create a client.
  ///
  /// [httpClient] is injectable so tests can run without any network access.
  TsdmHttpClient({
    required this.cookieStore,
    http.Client? httpClient,
    this.forceDesktop = true,
    this.userAgent = TsdmHttpConfig.userAgent,
  }) : _http = httpClient ?? http.Client();

  /// Injected transport used by this client.
  final http.Client _http;

  /// Cookie jar of this client.
  final TsdmCookieStore cookieStore;

  /// Whether the desktop layout query parameter is appended.
  ///
  /// The source passes `forceDesktop: false` when logging in so the mobile
  /// login form is returned.
  final bool forceDesktop;

  /// User agent header.
  final String userAgent;

  /// Points change values parsed from `set-cookie`, most recent first.
  final List<int> pointsChanges = [];

  /// The underlying transport, for tests that need to assert on it.
  http.Client get transport => _http;

  /// Close the underlying transport.
  void close() => _http.close();

  /// Build a no-cookie clone used by the login flow.
  TsdmHttpClient buildNoCookie({bool forceDesktop = false}) => TsdmHttpClient(
    cookieStore: TsdmCookieStore(),
    httpClient: _http,
    forceDesktop: forceDesktop,
    userAgent: userAgent,
  );

  /// Send a GET request.
  Future<TsdmHttpResponse> getUri(Uri uri) => _send('GET', uri);

  /// Send a GET request to [url].
  Future<TsdmHttpResponse> get(String url) => getUri(Uri.parse(url));

  /// Send a POST request carrying [data] as a form body.
  Future<TsdmHttpResponse> postForm(Uri uri, Map<String, String> data) =>
      _send('POST', uri, body: Uri(queryParameters: data).query);

  /// Send a request and return the decoded body as string.
  ///
  /// Throws [HttpRequestFailedException] for any non 200 response.
  Future<String> getDocument(Uri uri) async {
    final response = await _send('GET', uri);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    return response.data;
  }

  /// Fetch an image and return its bytes.
  ///
  /// Throws [HttpRequestFailedException] for any non 200 response.
  Future<Uint8List> getImage(Uri uri) async {
    final request = http.Request('GET', _applyDesktopParam(uri))
      ..headers.addAll({
        'accept': TsdmHttpConfig.imageAccept,
        'accept-encoding': 'deflate, br',
        'user-agent': userAgent,
      });
    final cookieHeader = cookieStore.buildCookieHeader();
    if (cookieHeader.isNotEmpty) {
      request.headers['cookie'] = cookieHeader;
    }
    final streamed = await _http.send(request);
    final response = await http.Response.fromStream(streamed);
    await _absorbCookies(response);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    return response.bodyBytes;
  }

  Future<TsdmHttpResponse> _send(String method, Uri uri, {String? body}) async {
    final target = _applyDesktopParam(uri);
    final headers = <String, String>{
      'accept': TsdmHttpConfig.accept,
      'accept-language': TsdmHttpConfig.acceptLanguage,
      'user-agent': userAgent,
    };
    if (!_keepGzip(target, method)) {
      headers['accept-encoding'] = 'deflate, br';
    }
    if (method == 'POST') {
      headers['content-type'] = TsdmHttpConfig.formContentType;
    }
    final cookieHeader = cookieStore.buildCookieHeader();
    if (cookieHeader.isNotEmpty) {
      headers['cookie'] = cookieHeader;
    }

    final request = http.Request(method, target)..headers.addAll(headers);
    if (body != null) {
      request.body = body;
    }

    try {
      final streamed = await _http.send(request);
      final response = await http.Response.fromStream(streamed);
      await _absorbCookies(response);
      return TsdmHttpResponse(
        statusCode: response.statusCode,
        data: decodeHttpBody(
          response.bodyBytes,
          response.headers['content-encoding'],
        ),
        realUri: response.request?.url ?? target,
        headers: response.headers,
        bodyBytes: response.bodyBytes,
      );
    } on TsdmException {
      rethrow;
    } catch (e) {
      throw HttpHandshakeFailedException('$e');
    }
  }

  Future<void> _absorbCookies(http.Response response) async {
    final setCookies = response.headersSplitValues['set-cookie'];
    if (setCookies == null) {
      return;
    }
    for (final raw in setCookies) {
      final parts = raw.split(';');
      final first = parts.first;
      final index = first.indexOf('=');
      if (index <= 0) {
        continue;
      }
      final name = first.substring(0, index).trim();
      final value = first.substring(index + 1).trim();
      if (name.isEmpty) {
        continue;
      }
      await cookieStore.write(name, value);
      if (name == tsdmCreditNoticeCookieName) {
        final credit = _creditNoticeRe
            .firstMatch(value)
            ?.namedGroup('value')
            ?.parseToIntSafe();
        if (credit != null) {
          pointsChanges.insert(0, credit);
        }
      }
    }
  }

  static final _creditNoticeRe = RegExp(
    '$tsdmCreditNoticeCookieName=(?<value>[^ ;]+)',
  );

  /// Force the desktop layout for forum requests only, as the source does.
  Uri _applyDesktopParam(Uri uri) {
    if (!forceDesktop) {
      return uri;
    }
    if (uri.host != TsdmApiUrls.baseHost &&
        uri.host != TsdmApiUrls.baseHostAlt) {
      return uri;
    }
    if (uri.queryParameters['mobile'] == 'no') {
      return uri;
    }
    return uri.replace(
      queryParameters: {...uri.queryParameters, 'mobile': 'no'},
    );
  }

  /// Whether the request keeps the default gzip accept encoding.
  ///
  /// The source removed gzip for any non GET request and for GET requests that
  /// redirect to a single post, because those answers were mangled by the
  /// server side gzip layer.
  bool _keepGzip(Uri uri, String method) {
    if (method != 'GET') {
      return false;
    }
    if (uri.queryParameters['goto'] == 'findpost') {
      return false;
    }
    return true;
  }
}

/// Decode a http body honoring the response `content-encoding`.
///
/// `dart:io` already decodes gzip, so only an explicit deflate header is
/// handled here; brotli responses are returned as-is and reported as a known
/// limitation of the port.
String decodeHttpBody(List<int> bytes, String? contentEncoding) {
  switch (contentEncoding) {
    case 'deflate':
      try {
        return utf8.decode(zlibDecodeBytes(bytes));
      } catch (_) {
        return utf8.decode(bytes, allowMalformed: true);
      }
    default:
      return utf8.decode(bytes, allowMalformed: true);
  }
}
