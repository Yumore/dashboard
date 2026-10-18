import 'package:shared_preferences/shared_preferences.dart';

/// Persists playback preferences: the last channel plus the source app's
/// `timeoutSwitchLine` and `dataValueProxy` settings.
class EasyTvSettingsStore {
  const EasyTvSettingsStore({SharedPreferences? preferences})
    : _preferences = preferences;

  final SharedPreferences? _preferences;

  static const prePlaySerialKey = 'easy_tv_live_pre_play_serial';
  static const timeoutKey = 'easy_tv_live_timeout_seconds';
  static const proxyKey = 'easy_tv_live_proxy_index';
  static const defaultTimeoutSeconds = 15;

  Future<SharedPreferences> _prefs() async =>
      _preferences ?? SharedPreferences.getInstance();

  /// The source app stores `prePlaySerialNum` (default 1).
  Future<int?> loadPrePlaySerial() async {
    final value = (await _prefs()).getInt(prePlaySerialKey);
    return value == null || value < 1 ? null : value;
  }

  Future<void> savePrePlaySerial(int serialNum) async {
    if (serialNum < 1) return;
    await (await _prefs()).setInt(prePlaySerialKey, serialNum);
  }

  Future<int> loadTimeoutSeconds() async {
    final value = (await _prefs()).getInt(timeoutKey);
    if (value == null) return defaultTimeoutSeconds;
    return value.clamp(5, 60);
  }

  Future<void> saveTimeoutSeconds(int seconds) async {
    await (await _prefs()).setInt(timeoutKey, seconds.clamp(5, 60));
  }

  Future<int> loadProxyIndex() async {
    final value = (await _prefs()).getInt(proxyKey);
    return value ?? 1;
  }

  Future<void> saveProxyIndex(int index) async {
    await (await _prefs()).setInt(proxyKey, index.clamp(0, 2));
  }
}
