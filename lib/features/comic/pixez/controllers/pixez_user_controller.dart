import 'package:flutter/foundation.dart';

import '../models/pixez_illust.dart';
import '../models/pixez_user_detail.dart';
import '../pixez_api_client.dart';
import '../pixez_auth_required_exception.dart';
import '../pixez_auth_store.dart';
import '../pixez_error.dart';
import '../pixez_load_status.dart';

/// User tab: profile header, works (illust/manga) and public bookmarks.
class PixezUserController extends ChangeNotifier {
  PixezUserController({
    required this.userId,
    PixezApiClient? client,
    PixezAuthStore? auth,
  }) : auth = client?.auth ?? auth ?? PixezAuthStore.instance,
       _client = client ?? PixezApiClient(auth: auth ?? PixezAuthStore.instance);

  final int userId;
  final PixezApiClient _client;
  final PixezAuthStore auth;

  final List<PixezIllust> _works = <PixezIllust>[];
  final List<PixezIllust> _bookmarks = <PixezIllust>[];
  PixezUserDetail? _detail;
  PixezLoadStatus _status = PixezLoadStatus.idle;
  String? _error;
  int _tabIndex = 0;
  String _worksType = 'illust';
  bool _worksHasMore = false;
  bool _bookmarksHasMore = false;
  bool _loading = false;
  bool _tabLoading = false;
  bool _loadingMore = false;
  bool _disposed = false;

  PixezLoadStatus get status => _status;
  PixezUserDetail? get detail => _detail;
  List<PixezIllust> get works => List<PixezIllust>.unmodifiable(_works);
  List<PixezIllust> get bookmarks =>
      List<PixezIllust>.unmodifiable(_bookmarks);
  String? get error => _error;
  int get tabIndex => _tabIndex;
  String get worksType => _worksType;
  bool get loading => _loading;
  bool get tabLoading => _tabLoading;
  bool get loadingMore => _loadingMore;
  bool get worksHasMore => _worksHasMore;
  bool get bookmarksHasMore => _bookmarksHasMore;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _status = PixezLoadStatus.loading;
    _error = null;
    _notify();
    try {
      _detail = await _client.getUserDetail(userId);
      await _loadWorks(reset: true);
      _status = PixezLoadStatus.ready;
    } catch (error) {
      _applyInitialError(error);
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> selectTab(int index) async {
    if (index < 0 || index > 2 || index == _tabIndex) return;
    _tabIndex = index;
    _error = null;
    _tabLoading = true;
    _notify();
    try {
      if (index == 2) {
        if (_bookmarks.isEmpty) await _loadBookmarks(reset: true);
      } else {
        final type = index == 1 ? 'manga' : 'illust';
        if (_worksType != type || _works.isEmpty) {
          _worksType = type;
          await _loadWorks(reset: true);
        }
      }
    } catch (error) {
      if (pixezIsAuthFailure(error)) {
        _status = PixezLoadStatus.loginRequired;
        _error = PixezAuthRequiredException.message;
      } else {
        _error = pixezErrorMessage(error);
      }
    } finally {
      _tabLoading = false;
      _notify();
    }
  }

  Future<void> loadMore() async {
    if (_loading || _tabLoading || _loadingMore) return;
    if (_tabIndex == 2) {
      if (!_bookmarksHasMore) return;
    } else if (!_worksHasMore) {
      return;
    }
    _loadingMore = true;
    _error = null;
    _notify();
    try {
      if (_tabIndex == 2) {
        await _loadBookmarks(reset: false);
      } else {
        await _loadWorks(reset: false);
      }
    } catch (error) {
      _error = pixezErrorMessage(error);
    } finally {
      _loadingMore = false;
      _notify();
    }
  }

  Future<void> _loadWorks({required bool reset}) async {
    final page = await _client.getUserIllusts(
      userId,
      type: _worksType,
      offset: reset ? 0 : _works.length,
    );
    if (reset) _works.clear();
    _works.addAll(page.items);
    _worksHasMore = page.items.isNotEmpty;
  }

  Future<void> _loadBookmarks({required bool reset}) async {
    final page = await _client.getUserBookmarksIllust(
      userId,
      restrict: 'public',
      offset: reset ? 0 : _bookmarks.length,
    );
    if (reset) _bookmarks.clear();
    _bookmarks.addAll(page.items);
    _bookmarksHasMore = page.items.isNotEmpty;
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
