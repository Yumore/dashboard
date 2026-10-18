import 'package:flutter/foundation.dart';

import '../models/pixez_illust.dart';
import '../models/pixez_search_options.dart';
import '../models/pixez_search_query.dart';
import '../models/pixez_user_preview.dart';
import '../pixez_api_client.dart';
import '../pixez_auth_required_exception.dart';
import '../pixez_auth_store.dart';
import '../pixez_error.dart';
import '../pixez_load_status.dart';

/// Search tab: illust results or user results, both paged by `next_url`.
class PixezSearchController extends ChangeNotifier {
  PixezSearchController({PixezApiClient? client, PixezAuthStore? auth})
    : auth = client?.auth ?? auth ?? PixezAuthStore.instance,
      _client = client ?? PixezApiClient(auth: auth ?? PixezAuthStore.instance);

  final PixezApiClient _client;
  final PixezAuthStore auth;

  final List<PixezIllust> _illusts = <PixezIllust>[];
  final List<PixezUserPreview> _users = <PixezUserPreview>[];
  PixezLoadStatus _status = PixezLoadStatus.idle;
  String? _error;
  String? _nextUrl;
  String _word = '';
  String _sort = PixezSearchOptions.defaultSort;
  String _searchTarget = PixezSearchOptions.defaultTarget;
  bool _showUsers = false;
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasSearched = false;
  bool _disposed = false;

  List<PixezIllust> get illusts => List<PixezIllust>.unmodifiable(_illusts);
  List<PixezUserPreview> get users =>
      List<PixezUserPreview>.unmodifiable(_users);
  PixezLoadStatus get status => _status;
  String? get error => _error;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _nextUrl != null && _nextUrl!.trim().isNotEmpty;
  String get word => _word;
  String get sort => _sort;
  String get searchTarget => _searchTarget;
  bool get showUsers => _showUsers;
  bool get hasSearched => _hasSearched;

  void setSort(String value) {
    if (!PixezSearchOptions.sorts.contains(value)) return;
    _sort = value;
  }

  void setSearchTarget(String value) {
    if (!PixezSearchOptions.targets.contains(value)) return;
    _searchTarget = value;
  }

  void setShowUsers(bool value) {
    _showUsers = value;
  }

  Future<void> search(String word) async {
    final trimmed = word.trim();
    _word = trimmed;
    if (trimmed.isEmpty) {
      _hasSearched = false;
      _status = PixezLoadStatus.error;
      _error = '请输入搜索关键词';
      _illusts.clear();
      _users.clear();
      _nextUrl = null;
      _notify();
      return;
    }
    if (_loading) return;
    _loading = true;
    _hasSearched = true;
    _status = PixezLoadStatus.loading;
    _error = null;
    _nextUrl = null;
    _illusts.clear();
    _users.clear();
    _notify();
    try {
      if (_showUsers) {
        final page = await _client.searchUser(trimmed);
        _users.addAll(page.items);
        _nextUrl = page.nextUrl;
      } else {
        final page = await _client.searchIllust(
          PixezSearchQuery(
            word: trimmed,
            sort: _sort,
            searchTarget: _searchTarget,
          ),
        );
        _illusts.addAll(page.items);
        _nextUrl = page.nextUrl;
      }
      _status = PixezLoadStatus.ready;
    } catch (error) {
      _applyInitialError(error);
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> loadMore() async {
    final next = _nextUrl;
    if (_loading || _loadingMore || next == null || next.trim().isEmpty) {
      return;
    }
    _loadingMore = true;
    _error = null;
    _notify();
    try {
      if (_showUsers) {
        final page = await _client.getNextUserPreviews(next);
        final knownIds = _users.map((preview) => preview.user.id).toSet();
        _users.addAll(
          page.items.where((preview) => !knownIds.contains(preview.user.id)),
        );
        _nextUrl = page.nextUrl;
      } else {
        final page = await _client.getNextIllusts(next);
        final knownIds = _illusts.map((illust) => illust.id).toSet();
        _illusts.addAll(
          page.items.where((illust) => !knownIds.contains(illust.id)),
        );
        _nextUrl = page.nextUrl;
      }
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
