import 'package:dashboard/features/live/live_channel.dart';
import 'package:dashboard/features/live/live_playlist_repository.dart';
import 'package:dashboard/features/live/live_subscription_store.dart';
import 'package:flutter/foundation.dart';

/// Owns live subscription state: the saved playlist URL, the parsed channels
/// and the load/error flags.
class LiveHubController extends ChangeNotifier {
  LiveHubController({
    LivePlaylistRepository? repository,
    LiveSubscriptionStore? store,
  }) : _repository = repository ?? LivePlaylistRepository(),
       _store = store ?? LiveSubscriptionStore();

  final LivePlaylistRepository _repository;
  final LiveSubscriptionStore _store;
  List<LiveChannel> _channels = const [];
  String? _error;
  bool _loading = false;
  bool _disposed = false;

  List<LiveChannel> get channels => _channels;
  String? get error => _error;
  bool get loading => _loading;

  /// Saved subscription URL restored across launches, if any.
  Future<String?> restore() => _store.load();

  /// Loads channels from [rawUrl]; returns false when the URL is invalid or
  /// the playlist cannot be fetched.
  Future<bool> load(String rawUrl) async {
    final source = Uri.tryParse(rawUrl.trim());
    if (source == null || !<String>['http', 'https'].contains(source.scheme)) {
      _error = '请输入 HTTP/HTTPS M3U 或 TXT 订阅地址';
      notifyListeners();
      return false;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final channels = await _repository.load(source);
      await _store.save(source.toString());
      if (_disposed) return true;
      _channels = channels;
      return true;
    } catch (error) {
      if (!_disposed) _error = error.toString();
      return false;
    } finally {
      if (!_disposed) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.dispose();
    super.dispose();
  }
}
