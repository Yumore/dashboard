import 'package:dashboard/features/anime/tsdm/tsdm_cookie_store.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notice.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notification_controller.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notification_page.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notification_repository.dart';
import 'package:flutter/material.dart';

/// State of [TsdmNotificationPage].
class TsdmNotificationPageState extends State<TsdmNotificationPage>
    with SingleTickerProviderStateMixin {
  late final TsdmNotificationController _controller;
  late final TabController _tabController;
  TsdmHttpClient? _ownedClient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final client =
        widget.client ??
        (_ownedClient = TsdmHttpClient(cookieStore: TsdmCookieStore()));
    _controller = TsdmNotificationController(
      repository:
          widget.repository ?? TsdmNotificationRepository(client: client),
    )..addListener(_onControllerChanged);
    _controller.fetchNotices();
    _controller.fetchPersonalMessages();
    _controller.fetchBroadcastMessages();
    if (widget.uid > 0) {
      _controller.fetchNotificationV2(uid: widget.uid);
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _tabController.dispose();
    _ownedClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '提醒 ${_controller.noticeList.length}'),
            Tab(text: '私信 ${_controller.personalMessageList.length}'),
            Tab(text: '广播 ${_controller.broadcastMessageList.length}'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotices(),
          _buildPersonalMessages(),
          _buildBroadcastMessages(),
        ],
      ),
    );
  }

  Widget _buildNotices() {
    if (_controller.status == TsdmNotificationStatus.loading &&
        _controller.noticeList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.noticeList.isEmpty) {
      return Center(
        child: Text(
          _controller.error == null ? '没有提醒' : '加载失败：${_controller.error}',
        ),
      );
    }
    return ListView.builder(
      itemCount: _controller.noticeList.length,
      itemBuilder: (context, index) {
        final TsdmNotice notice = _controller.noticeList[index];
        return ListTile(
          title: Text('${notice.username ?? ''} ${notice.noticeType.name}'),
          subtitle: Text(
            notice.quotedMessage ?? notice.noticeThreadTitle ?? '',
          ),
          trailing: Text(notice.noticeTimeString),
        );
      },
    );
  }

  Widget _buildPersonalMessages() {
    if (_controller.personalMessageList.isEmpty) {
      return const Center(child: Text('没有私信'));
    }
    return ListView.builder(
      itemCount: _controller.personalMessageList.length,
      itemBuilder: (context, index) {
        final message = _controller.personalMessageList[index];
        return ListTile(
          title: Text(message.user.name),
          subtitle: Text('${message.message} · ${message.lastMessageTime}'),
        );
      },
    );
  }

  Widget _buildBroadcastMessages() {
    if (_controller.broadcastMessageList.isEmpty) {
      return const Center(child: Text('没有广播'));
    }
    return ListView.builder(
      itemCount: _controller.broadcastMessageList.length,
      itemBuilder: (context, index) {
        final message = _controller.broadcastMessageList[index];
        return ListTile(
          title: Text(message.message),
          subtitle: Text('${message.messageTime}'),
        );
      },
    );
  }
}
