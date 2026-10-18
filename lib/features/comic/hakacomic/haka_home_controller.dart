import 'package:flutter/foundation.dart';
import 'package:dashboard/features/comic/hakacomic/haka_category.dart';
import 'package:dashboard/features/comic/hakacomic/haka_failure.dart';
import 'package:dashboard/features/comic/hakacomic/haka_initial.dart';
import 'package:dashboard/features/comic/hakacomic/haka_loading.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';
import 'package:dashboard/features/comic/hakacomic/haka_request_state.dart';
import 'package:dashboard/features/comic/hakacomic/haka_success.dart';

/// Loads the home category grid.
///
/// Web-only categories are dropped by [HakaRepository.fetchCategories], exactly
/// as upstream did before parsing.
class HakaHomeController extends ChangeNotifier {
  HakaHomeController({required this.repository});

  final HakaRepository repository;

  HakaRequestState<List<HakaCategory>> _state =
      const HakaInitial<List<HakaCategory>>();

  HakaRequestState<List<HakaCategory>> get state => _state;

  bool _disposed = false;

  Future<void> load() async {
    _state = HakaLoading<List<HakaCategory>>(_state.data);
    _notify();
    try {
      final categories = await repository.fetchCategories();
      _state = HakaSuccess<List<HakaCategory>>(categories);
    } catch (error) {
      _state = HakaFailure<List<HakaCategory>>(error);
    }
    _notify();
  }

  Future<void> refresh() => load();

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
