import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notification_page_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notification_repository.dart';
import 'package:flutter/material.dart';

/// Notification page: notices, personal messages and broadcast messages.
///
/// Ported from `tsdm_client/lib/features/notification/view/notification_page.dart`.
class TsdmNotificationPage extends StatefulWidget {
  /// Create a notification page.
  const TsdmNotificationPage({
    this.uid = 0,
    this.client,
    this.repository,
    super.key,
  });

  /// Uid the mobile notification endpoint is queried for, `0` skips it.
  final int uid;

  /// Injected transport, a new one is created when omitted.
  final TsdmHttpClient? client;

  /// Injected repository, built from [client] when omitted.
  final TsdmNotificationRepository? repository;

  @override
  State<TsdmNotificationPage> createState() => TsdmNotificationPageState();
}
