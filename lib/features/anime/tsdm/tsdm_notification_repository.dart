import 'dart:convert';

import 'package:dashboard/features/anime/tsdm/tsdm_api_urls.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_exception.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_message.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notice.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notification_v2.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user_login_info.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Fetch notices, private messages and broadcast messages.
///
/// Ported from `tsdm_client/lib/features/notification/repository/notification_repository.dart`
/// and `notification_info_repository.dart`.
class TsdmNotificationRepository {
  /// Create the repository.
  const TsdmNotificationRepository({required this.client});

  /// Transport used by this repository.
  final TsdmHttpClient client;

  /// Fetch the notice page and parse its notice list.
  Future<List<TsdmNotice>> fetchNoticeList() async {
    final document = await _fetchDocument(TsdmApiUrls.noticeUrl);
    return parseTsdmNoticeList(document);
  }

  /// Fetch the personal message page and parse its session list.
  ///
  /// The source reads every `dl` under `form#deletepmform > div`.
  Future<List<TsdmPersonalMessage>> fetchPersonalMessage() async {
    final document = await _fetchDocument(TsdmApiUrls.personalMessageUrl);
    return _parseMessageList(document, TsdmPersonalMessage.fromDl);
  }

  /// Fetch the broadcast message page and parse its message list.
  Future<List<TsdmBroadcastMessage>> fetchBroadcastMessage() async {
    final document = await _fetchDocument(TsdmApiUrls.broadcastMessageUrl);
    return _parseMessageList(document, TsdmBroadcastMessage.fromDl);
  }

  /// Fetch a url and parse the response body.
  Future<dom.Document> _fetchDocument(String url) async {
    final response = await client.get(url);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    return html_parser.parse(response.data);
  }

  static List<T> _parseMessageList<T>(
    dom.Document document,
    T? Function(dom.Element element) parse,
  ) {
    final result = <T>[];
    for (final element in document.qAll('form#deletepmform > div > dl')) {
      final message = parse(element);
      if (message != null) {
        result.add(message);
      }
    }
    return result;
  }

  /// Build the url of the mobile notification API.
  ///
  /// Ported from the private `_buildNotificationV2Url`: [timestamp] is used
  /// only when it is at most three days old, otherwise the request asks for
  /// notifications of the last three days.
  static String buildNotificationV2Url({DateTime? timestamp}) {
    final now = DateTime.now();
    final int argTimestamp;
    if (timestamp != null &&
        !now.difference(timestamp).isNegative &&
        now.difference(timestamp).inDays <= 3) {
      argTimestamp = timestamp.millisecondsSinceEpoch ~/ 1000;
    } else {
      argTimestamp =
          now.add(const Duration(days: -3)).millisecondsSinceEpoch ~/ 1000;
    }
    return '${TsdmApiUrls.notificationV2UrlPrefix}$argTimestamp';
  }

  /// Fetch and parse the mobile notification API.
  ///
  /// Returns the parsed notifications and the `page` query parameter of the
  /// effective uri, if the server provided one. A body that is not a json
  /// object yields null notifications.
  Future<(TsdmNotificationV2?, String?)> fetchNotificationV2({
    required int uid,
    DateTime? timestamp,
  }) async {
    final response = await client.get(
      buildNotificationV2Url(timestamp: timestamp),
    );
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    final decoded = jsonDecode(response.data);
    final notifications = decoded is Map
        ? TsdmNotificationV2.fromJson(decoded.cast<String, Object?>())
        : null;
    return (notifications, response.realUri.queryParameters['page']);
  }

  /// Whether [userInfo] may request notifications of the mobile API.
  static bool canSync(TsdmUserLoginInfo userInfo) => userInfo.isComplete;
}
