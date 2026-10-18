/// A notice returned by the mobile notification API.
///
/// Hand-written replacement for the dart_mappable model
/// `NoticeV2` in `tsdm_client/lib/features/notification/models/notice_v2.dart`.
class TsdmNoticeV2 {
  /// Create a notice.
  const TsdmNoticeV2({
    required this.id,
    required this.timestamp,
    required this.data,
    this.alreadyRead = false,
  });

  /// Notice id.
  final int id;

  /// Timestamp in seconds.
  final int timestamp;

  /// Notice data in html format, mapped from the json key `html`.
  final String data;

  /// Whether the notice was read.
  final bool alreadyRead;

  /// Parse from a json object, null when mandatory fields are missing.
  static TsdmNoticeV2? fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final timestamp = json['timestamp'];
    final data = json['html'];
    if (id is! int || timestamp is! int || data is! String) {
      return null;
    }
    return TsdmNoticeV2(
      id: id,
      timestamp: timestamp,
      data: data,
      alreadyRead: json['already_read'] == true,
    );
  }
}

/// A private message returned by the mobile notification API.
///
/// Hand-written replacement for the dart_mappable model
/// `PersonalMessageV2`; the source uses snake_case, so the json keys are
/// `timestamp`, `message`, `peer_uid`, `peer_username`, `send` and `read`.
class TsdmPersonalMessageV2 {
  /// Create a private message.
  const TsdmPersonalMessageV2({
    required this.timestamp,
    required this.data,
    required this.peerUid,
    required this.peerUsername,
    required this.sender,
    required this.alreadyRead,
  });

  /// Timestamp in seconds.
  final int timestamp;

  /// Message content in plain text, mapped from the json key `message`.
  final String data;

  /// Uid of the user chatting with.
  final int peerUid;

  /// Username of the user chatting with.
  final String peerUsername;

  /// Whether the current user is the sender, mapped from `send`.
  final bool sender;

  /// Whether the message was read, mapped from `read`.
  final bool alreadyRead;

  /// Parse from a json object, null when mandatory fields are missing.
  static TsdmPersonalMessageV2? fromJson(Map<String, Object?> json) {
    final timestamp = json['timestamp'];
    final data = json['message'];
    final peerUid = json['peer_uid'];
    final peerUsername = json['peer_username'];
    if (timestamp is! int ||
        data is! String ||
        peerUid is! int ||
        peerUsername is! String) {
      return null;
    }
    return TsdmPersonalMessageV2(
      timestamp: timestamp,
      data: data,
      peerUid: peerUid,
      peerUsername: peerUsername,
      sender: json['send'] == true,
      alreadyRead: json['read'] == true,
    );
  }
}

/// A broadcast message returned by the mobile notification API.
///
/// Hand-written replacement for the dart_mappable model `BroadcastMessageV2`.
class TsdmBroadcastMessageV2 {
  /// Create a broadcast message.
  const TsdmBroadcastMessageV2({
    required this.timestamp,
    required this.data,
    required this.pmid,
    this.alreadyRead = false,
  });

  /// Timestamp in seconds.
  final int timestamp;

  /// Content preview in plain text, mapped from the json key `preview`.
  final String data;

  /// Message id.
  final int pmid;

  /// Whether the message was read.
  final bool alreadyRead;

  /// Parse from a json object, null when mandatory fields are missing.
  static TsdmBroadcastMessageV2? fromJson(Map<String, Object?> json) {
    final timestamp = json['timestamp'];
    final data = json['preview'];
    final pmid = json['pmid'];
    if (timestamp is! int || data is! String || pmid is! int) {
      return null;
    }
    return TsdmBroadcastMessageV2(
      timestamp: timestamp,
      data: data,
      pmid: pmid,
      alreadyRead: json['already_read'] == true,
    );
  }
}

/// Result of the mobile notification API.
///
/// Hand-written replacement for the dart_mappable model `NotificationV2`.
/// The source maps `notification` to the notice list, `private_message` to the
/// personal message list and `public_message` to the broadcast message list.
class TsdmNotificationV2 {
  /// Create a notification result.
  const TsdmNotificationV2({
    required this.status,
    required this.noticeList,
    required this.personalMessageList,
    required this.broadcastMessageList,
  });

  /// Response status.
  final int status;

  /// All notices, mapped from the json key `notification`.
  final List<TsdmNoticeV2> noticeList;

  /// All private messages, mapped from the json key `private_message`.
  final List<TsdmPersonalMessageV2> personalMessageList;

  /// All broadcast messages, mapped from the json key `public_message`.
  final List<TsdmBroadcastMessageV2> broadcastMessageList;

  /// Parse from a decoded json object.
  static TsdmNotificationV2 fromJson(Map<String, Object?> json) {
    final status = json['status'];
    return TsdmNotificationV2(
      status: status is int ? status : 0,
      noticeList: _parseList(json['notification'], TsdmNoticeV2.fromJson),
      personalMessageList: _parseList(
        json['private_message'],
        TsdmPersonalMessageV2.fromJson,
      ),
      broadcastMessageList: _parseList(
        json['public_message'],
        TsdmBroadcastMessageV2.fromJson,
      ),
    );
  }

  static List<T> _parseList<T>(
    Object? value,
    T? Function(Map<String, Object?> json) parse,
  ) {
    if (value is! List) {
      return const [];
    }
    final result = <T>[];
    for (final item in value) {
      if (item is Map) {
        final parsed = parse(item.cast<String, Object?>());
        if (parsed != null) {
          result.add(parsed);
        }
      }
    }
    return result;
  }

  /// Datetime of the latest notification of any type, null when all lists are
  /// empty.
  ///
  /// All timestamps are in seconds, so the result is built from
  /// `timestamp * 1000` milliseconds.
  DateTime? latestTimestamp() {
    final noticeTime = noticeList.isEmpty
        ? 0
        : noticeList.map((e) => e.timestamp).reduce(_max);
    final pmTime = personalMessageList.isEmpty
        ? 0
        : personalMessageList.map((e) => e.timestamp).reduce(_max);
    final bmTime = broadcastMessageList.isEmpty
        ? 0
        : broadcastMessageList.map((e) => e.timestamp).reduce(_max);
    final latestTime = [noticeTime, pmTime, bmTime].reduce(_max);
    if (latestTime == 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(latestTime * 1000);
  }

  static int _max(int a, int b) => a > b ? a : b;
}
