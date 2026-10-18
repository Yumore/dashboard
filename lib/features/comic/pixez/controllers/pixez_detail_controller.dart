import 'package:flutter/foundation.dart';

import '../models/pixez_bookmark_detail.dart';
import '../models/pixez_illust.dart';
import '../pixez_api_client.dart';
import '../pixez_auth_required_exception.dart';
import '../pixez_auth_store.dart';
import '../pixez_error.dart';
import '../pixez_load_status.dart';

/// Detail tab: illust detail, related works, bookmark state and follow state.
class PixezDetailController extends ChangeNotifier {
  PixezDetailController({
    required this.illustId,
    PixezApiClient? client,
    PixezAuthStore? auth,
  }) : auth = client?.auth ?? auth ?? PixezAuthStore.instance,
       _client = client ?? PixezApiClient(auth: auth ?? PixezAuthStore.instance);

  final int illustId;
  final PixezApiClient _client;
  final PixezAuthStore auth;

  final List<PixezIllust> _related = <PixezIllust>[];
  PixezLoadStatus _status = PixezLoadStatus.idle;
  PixezIllust? _illust;
  PixezBookmarkDetail? _bookmarkDetail;
  String? _error;
  String? _actionError;
  String? _relatedNextUrl;
  bool _bookmarked = false;
  bool _following = false;
  bool _loading = false;
  bool _loadingMoreRelated = false;
  bool _actionBusy = false;
  bool _disposed = false;

  PixezLoadStatus get status => _status;
  PixezIllust? get illust => _illust;
  PixezBookmarkDetail? get bookmarkDetail => _bookmarkDetail;
  List<PixezIllust> get related => List<PixezIllust>.unmodifiable(_related);
  String? get error => _error;
  String? get actionError => _actionError;
  bool get bookmarked => _bookmarked;
  bool get following => _following;
  bool get loading => _loading;
  bool get loadingMoreRelated => _loadingMoreRelated;
  bool get actionBusy => _actionBusy;
  bool get hasMoreRelated =>
      _relatedNextUrl != null && _relatedNextUrl!.trim().isNotEmpty;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _status = PixezLoadStatus.loading;
    _error = null;
    _actionError = null;
    _notify();
    try {
      final detail = await _client.getIllustDetail(illustId);
      final related = await _client.getRelatedIllusts(illustId);
      _illust = detail;
      _related
        ..clear()
        ..addAll(related.items);
      _relatedNextUrl = related.nextUrl;
      _bookmarked = detail.isBookmarked;
      _following = detail.user.isFollowed ?? false;
      _status = PixezLoadStatus.ready;
      // Bookmark detail is optional: a missing tag list must not hide the work.
      try {
        final bookmark = await _client.getIllustBookmarkDetail(illustId);
        _bookmarkDetail = bookmark;
        _bookmarked = bookmark.isBookmarked;
      } catch (_) {
        _bookmarkDetail = null;
      }
    } catch (error) {
      _applyInitialError(error);
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> loadMoreRelated() async {
    final next = _relatedNextUrl;
    if (_loading || _loadingMoreRelated || next == null) return;
    _loadingMoreRelated = true;
    _notify();
    try {
      final page = await _client.getNextIllusts(next);
      final knownIds = _related.map((illust) => illust.id).toSet();
      _related.addAll(
        page.items.where((illust) => !knownIds.contains(illust.id)),
      );
      _relatedNextUrl = page.nextUrl;
    } catch (error) {
      _actionError = pixezErrorMessage(error);
    } finally {
      _loadingMoreRelated = false;
      _notify();
    }
  }

  Future<void> toggleBookmark() async {
    if (_actionBusy) return;
    if (!auth.hasAccessToken) {
      _actionError = PixezAuthRequiredException.message;
      _notify();
      return;
    }
    _actionBusy = true;
    _actionError = null;
    _notify();
    try {
      if (_bookmarked) {
        await _client.deleteIllustBookmark(illustId);
      } else {
        await _client.addIllustBookmark(
          illustId,
          restrict: _bookmarkDetail?.restrict ?? 'public',
          tags: _bookmarkDetail?.tags ?? const <String>[],
        );
      }
      _bookmarked = !_bookmarked;
    } catch (error) {
      _actionError = pixezIsAuthFailure(error)
          ? PixezAuthRequiredException.message
          : pixezErrorMessage(error);
    } finally {
      _actionBusy = false;
      _notify();
    }
  }

  Future<void> toggleFollow() async {
    if (_actionBusy || _illust == null) return;
    if (!auth.hasAccessToken) {
      _actionError = PixezAuthRequiredException.message;
      _notify();
      return;
    }
    _actionBusy = true;
    _actionError = null;
    _notify();
    try {
      if (_following) {
        await _client.unfollowUser(_illust!.user.id);
      } else {
        await _client.followUser(_illust!.user.id);
      }
      _following = !_following;
    } catch (error) {
      _actionError = pixezIsAuthFailure(error)
          ? PixezAuthRequiredException.message
          : pixezErrorMessage(error);
    } finally {
      _actionBusy = false;
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
