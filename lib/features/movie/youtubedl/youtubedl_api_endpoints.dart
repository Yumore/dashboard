/// InnerTube endpoints and request bodies used to extract YouTube streams.
///
/// The `WEB` client with YouTube's public InnerTube key is used because it
/// returns direct `url` fields for many formats. Formats that only expose a
/// `signatureCipher` still need a JavaScript signature solver and are therefore
/// reported as unavailable by the parser.
class YoutubeDlApiEndpoints {
  const YoutubeDlApiEndpoints._();

  static const String origin = 'https://www.youtube.com';
  static const String host = 'www.youtube.com';
  static const String publicApiKey = 'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
  static const String clientName = 'WEB';
  static const String clientVersion = '2.20241010.00.00';
  static const String language = 'en';
  static const String region = 'US';

  static Uri player(String videoId) => _innertube('player');

  static Uri search() => _innertube('search');

  static Uri suggestions(String query) => Uri.https(
    'suggestqueries.google.com',
    '/complete/search',
    <String, String>{'client': 'firefox', 'ds': 'yt', 'q': query},
  );

  static Uri _innertube(String method) {
    return Uri.https(host, '/youtubei/v1/$method', <String, String>{
      'key': publicApiKey,
      'prettyPrint': 'false',
    });
  }

  static Map<String, dynamic> clientContext() {
    return <String, dynamic>{
      'client': <String, dynamic>{
        'clientName': clientName,
        'clientVersion': clientVersion,
        'hl': language,
        'gl': region,
      },
    };
  }

  static Map<String, dynamic> playerBody(String videoId) {
    return <String, dynamic>{
      'context': clientContext(),
      'videoId': videoId,
      'contentCheckOk': true,
      'racyCheckOk': true,
    };
  }

  static Map<String, dynamic> searchBody(String query, {String? continuation}) {
    final body = <String, dynamic>{'context': clientContext()};
    if (continuation != null && continuation.isNotEmpty) {
      body['continuation'] = continuation;
    } else {
      body['query'] = query;
    }
    return body;
  }
}
