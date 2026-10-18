import 'package:shared_preferences/shared_preferences.dart';

/// The source's `useNetData` switch, kept under the same preference key.
///
/// Source semantics (`lib/repository/movie_repository.dart:44-49`): read
/// `CacheKey.USE_NET_DATA` (`lib/constant/cache_key.dart:2`) and fall back to
/// the mock path when unset. The host flips the *default* — this port defaults
/// to the real network path and exposes the toggle in the app bar — while the
/// stored flag keeps the same meaning and key.
class FlutterDouBanSettingsStore {
  const FlutterDouBanSettingsStore();

  /// `CacheKey.USE_NET_DATA`, verbatim from the source.
  static const String useNetDataKey = 'USE_NET_DATA';

  /// The source defaulted to `false` (mock); the host defaults to the network.
  static const bool defaultUseNetData = true;

  Future<bool> loadUseNetData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(useNetDataKey) ?? defaultUseNetData;
  }

  Future<void> saveUseNetData(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(useNetDataKey, value);
  }
}
