import 'package:dashboard/features/anime/tsdm/tsdm_message.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notice.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notification_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notification_v2.dart';
import 'package:flutter/foundation.dart';

/// Loading status of a notification request.
enum TsdmNotificationStatus {
  /// Nothing requested yet.
  initial,

  /// A request is in flight.
  loading,

  /// The last request succeeded.
  success,

  /// The last request failed.
  failure,
}

/// Unread counters kept in the controller.
///
/// Ported from `NotificationStateInfo` of
/// `tsdm_client/lib/features/notification/models/notification_info_state.dart`.
class TsdmNotificationStateInfo {
  /// Create an unread counter snapshot.
  const TsdmNotificationStateInfo({
    required this.unreadNoticeCount,
    required this.unreadPersonalMessageCount,
    required this.unreadBroadcastMessageCount,
  });

  /// Unread notice count.
  final int unreadNoticeCount;

  /// Unread private message count.
  final int unreadPersonalMessageCount;

  /// Unread broadcast message count.
  final int unreadBroadcastMessageCount;
}

/// Controller of the notification feature.
///
/// Replaces the rxdart `BehaviorSubject` based
/// `tsdm_client/lib/features/notification/repository/notification_repository.dart`
/// state with a [ChangeNotifier], because the host pubspec has no rxdart.
class TsdmNotificationController extends ChangeNotifier {
  /// Create a controller.
  TsdmNotificationController({required this.repository});

  /// Repository used to fetch notifications.
  final TsdmNotificationRepository repository;

  /// Current status.
  TsdmNotificationStatus status = TsdmNotificationStatus.initial;

  /// Unread counters of the last notification request.
  TsdmNotificationStateInfo info = const TsdmNotificationStateInfo(
    unreadNoticeCount: 0,
    unreadPersonalMessageCount: 0,
    unreadBroadcastMessageCount: 0,
  );

  /// Notices of the notice page.
  List<TsdmNotice> noticeList = const [];

  /// Private message sessions.
  List<TsdmPersonalMessage> personalMessageList = const [];

  /// Broadcast messages.
  List<TsdmBroadcastMessage> broadcastMessageList = const [];

  /// Result of the last mobile notification api request.
  TsdmNotificationV2? notificationV2;

  /// Page reported by the mobile notification api.
  String? notificationPage;

  /// Error of the last failed request.
  Object? error;

  /// Update the unread counters from [unreadNoticeCount],
  /// [unreadPersonalMessageCount] and [unreadBroadcastMessageCount].
  void updateInfo({
    required int unreadNoticeCount,
    required int unreadPersonalMessageCount,
    required int unreadBroadcastMessageCount,
  }) {
    info = TsdmNotificationStateInfo(
      unreadNoticeCount: unreadNoticeCount,
      unreadPersonalMessageCount: unreadPersonalMessageCount,
      unreadBroadcastMessageCount: unreadBroadcastMessageCount,
    );
    notifyListeners();
  }

  /// Fetch the notice list.
  Future<void> fetchNotices() async {
    status = TsdmNotificationStatus.loading;
    notifyListeners();
    try {
      noticeList = await repository.fetchNoticeList();
      status = TsdmNotificationStatus.success;
    } on Object catch (e) {
      error = e;
      status = TsdmNotificationStatus.failure;
    }
    notifyListeners();
  }

  /// Fetch the private message sessions.
  Future<void> fetchPersonalMessages() async {
    status = TsdmNotificationStatus.loading;
    notifyListeners();
    try {
      personalMessageList = await repository.fetchPersonalMessage();
      status = TsdmNotificationStatus.success;
    } on Object catch (e) {
      error = e;
      status = TsdmNotificationStatus.failure;
    }
    notifyListeners();
  }

  /// Fetch the broadcast messages.
  Future<void> fetchBroadcastMessages() async {
    status = TsdmNotificationStatus.loading;
    notifyListeners();
    try {
      broadcastMessageList = await repository.fetchBroadcastMessage();
      status = TsdmNotificationStatus.success;
    } on Object catch (e) {
      error = e;
      status = TsdmNotificationStatus.failure;
    }
    notifyListeners();
  }

  /// Fetch the mobile notification api for user [uid].
  ///
  /// [timestamp] is the datetime of the latest already known notification.
  Future<void> fetchNotificationV2({
    required int uid,
    DateTime? timestamp,
  }) async {
    status = TsdmNotificationStatus.loading;
    notifyListeners();
    try {
      final (notifications, page) = await repository.fetchNotificationV2(
        uid: uid,
        timestamp: timestamp,
      );
      notificationV2 = notifications;
      notificationPage = page;
      status = TsdmNotificationStatus.success;
    } on Object catch (e) {
      error = e;
      status = TsdmNotificationStatus.failure;
    }
    notifyListeners();
  }
}
