import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_load_status.dart';
import 'package:flutter/foundation.dart';

/// The community half of `lib/blocs/main_bloc.dart` → `MainBloc.getRecommendData`.
///
/// The source was a bloc with a `StreamController<List<Item>>`; the port is a
/// [ChangeNotifier] so the page can rebuild with `ListenableBuilder` and the
/// paging rules stay assertable without a widget tree. All three source rules
/// are kept verbatim:
///
/// * a refresh asks with an **empty** `nextPageUrl` (an empty target makes the
///   repository hit the plain endpoint); a load-more reuses the `nextPageUrl`
///   the previous response returned;
/// * only `communityColumnsCard` items are kept out of the response;
/// * the response's `itemList` is checked for emptiness **before** the refresh
///   clears the list, so a refresh that comes back empty leaves the previous
///   items on screen.
class EyepetizerFlutterCommunityBloc extends ChangeNotifier {
  EyepetizerFlutterCommunityBloc({
    EyepetizerFlutterCommunityRepository? repository,
  }) : _ownsRepository = repository == null,
       _repository = repository ?? EyepetizerFlutterCommunityRepository();

  /// `MainBloc`'s filter: `value.type == "communityColumnsCard"`.
  static const String columnCardType = 'communityColumnsCard';

  final EyepetizerFlutterCommunityRepository _repository;
  final bool _ownsRepository;
  final List<EyepetizerFlutterItem> _items = <EyepetizerFlutterItem>[];
  String? _nextPageUrl;
  EyepetizerFlutterLoadStatus _loadStatus = EyepetizerFlutterLoadStatus.init;
  Object? _error;
  bool _loading = false;
  bool _disposed = false;

  List<EyepetizerFlutterItem> get items =>
      List<EyepetizerFlutterItem>.unmodifiable(_items);

  String? get nextPageUrl => _nextPageUrl;

  EyepetizerFlutterLoadStatus get loadStatus => _loadStatus;

  Object? get error => _error;

  bool get loading => _loading;

  Future<void> refresh() => load(isRefresh: true);

  Future<void> loadMore() => load(isRefresh: false);

  /// One page, either the first ([isRefresh]) or the next.
  Future<void> load({required bool isRefresh}) async {
    if (_loading) return;
    _loading = true;
    _loadStatus = EyepetizerFlutterLoadStatus.loading;
    _error = null;
    _notify();
    try {
      final result = await _repository.getCommunityRecommendData(
        nextPageUrl: isRefresh ? '' : _nextPageUrl,
      );
      _nextPageUrl = result.nextPageUrl;
      if (result.itemList.isNotEmpty) {
        final cards = result.itemList
            .where((item) => item.type == columnCardType)
            .toList();
        if (isRefresh) {
          _items.clear();
        }
        _items.addAll(cards);
      }
      _loadStatus = EyepetizerFlutterLoadStatus.completed;
    } catch (error) {
      _error = error;
      _loadStatus = EyepetizerFlutterLoadStatus.init;
    } finally {
      _loading = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }
}
