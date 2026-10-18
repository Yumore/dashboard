import 'package:flutter/foundation.dart';
import 'package:dashboard/features/comic/hakacomic/haka_failure.dart';
import 'package:dashboard/features/comic/hakacomic/haka_initial.dart';
import 'package:dashboard/features/comic/hakacomic/haka_loading.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';
import 'package:dashboard/features/comic/hakacomic/haka_request_state.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_history_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_success.dart';

/// Drives the search landing screen: recent terms plus hot keywords.
class HakaSearchController extends ChangeNotifier {
  HakaSearchController({required this.repository, required this.historyStore});

  final HakaRepository repository;

  final HakaSearchHistoryStore historyStore;

  HakaRequestState<List<String>> _hotWordsState =
      const HakaInitial<List<String>>();

  List<String> _history = const [];

  bool _disposed = false;

  HakaRequestState<List<String>> get hotWordsState => _hotWordsState;

  /// Most-recent-first, capped at [HakaSearchHistoryStore.maxEntries].
  List<String> get history => List.unmodifiable(_history);

  /// Recent terms, falling back to hot words while the user has no history.
  List<String> get suggestions =>
      _history.isNotEmpty ? _history : (_hotWordsState.data ?? const []);

  void loadHistory() {
    _history = historyStore.read();
    _notify();
  }

  Future<void> loadHotWords() async {
    _hotWordsState = HakaLoading<List<String>>(_hotWordsState.data);
    _notify();
    try {
      _hotWordsState = HakaSuccess<List<String>>(
        await repository.fetchHotSearchWords(),
      );
    } catch (error) {
      _hotWordsState = HakaFailure<List<String>>(error);
    }
    _notify();
  }

  /// Records a submitted term and returns the new history.
  Future<List<String>> record(String term) async {
    _history = await historyStore.add(term);
    _notify();
    return _history;
  }

  Future<void> removeHistory(String term) async {
    await historyStore.remove(term);
    loadHistory();
  }

  Future<void> clearHistory() async {
    await historyStore.clear();
    loadHistory();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
