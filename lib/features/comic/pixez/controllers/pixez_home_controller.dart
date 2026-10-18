import 'package:flutter/foundation.dart';

import '../models/pixez_illust.dart';
import '../pixez_api_client.dart';
import '../pixez_auth_required_exception.dart';
import '../pixez_auth_store.dart';
import '../pixez_error.dart';
import '../pixez_load_status.dart';

/// Home tab: `/v1/illust/recommended` plus its `next_url` paging.
class PixezHomeController extends ChangeNotifier {
  PixezHomeController({PixezApiClient? client, PixezAuthStore? auth})
    : auth = client?.auth ?? auth ?? PixezAuthStore.instance,
      _client = client ?? PixezApiClient(auth: auth ?? PixezAuthStore.instance);

  final PixezApiClient _client;
  final PixezAuthStore auth;

  final List<PixezIllust> _illusts = <PixezIllust>[];
  PixezLoadStatus _status = PixezLoadStatus.idle;
  String? _error;
  String? _nextUrl;
  bool _loading = false;
  bool _loadingMore = false;
  bool _disposed = false;

  List<PixezIllust> get illusts => List<PixezIllust>.unmodifiable(_illusts);
  PixezLoadStatus get status => _status;
  String? get error => _error;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _nextUrl != null && _nextUrl!.trim().isNotEmpty;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _status = PixezLoadStatus.loading;
    _error = null;
    _notify();
    try {
      final result = await _client.getIllustRecommended();
      _illusts
        ..clear()
        ..addAll(result.illusts);
      _nextUrl = result.nextUrl;
      _status = PixezLoadStatus.ready;
    } catch (error) {
      _applyInitialError(error);
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    final next = _nextUrl;
    if (_loading || _loadingMore || next == null || next.trim().isEmpty) {
      return;
    }
    _loadingMore = true;
    _error = null;
    _notify();
    try {
      final page = await _client.getNextIllusts(next);
      final knownIds = _illusts.map((illust) => illust.id).toSet();
      _illusts.addAll(
        page.items.where((illust) => !knownIds.contains(illust.id)),
      );
      _nextUrl = page.nextUrl;
    } catch (error) {
      if (pixezIsAuthFailure(error)) {
        _status = PixezLoadStatus.loginRequired;
        _error = PixezAuthRequiredException.message;
      } else {
        _error = pixezErrorMessage(error);
      }
    } finally {
      _loadingMore = false;
      _notify();
    }
  }

  void _applyInitialError(Object error) {
    if (pixezIsAuthFailure(error)) {
      _status = PixezLoadStatus.loginRequired;
      _error = PixezAuthRequiredException.message;
    } else {
      _status = PixezLoadStatus.error;
      _error = pixezErrorMessage(error);
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
