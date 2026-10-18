import 'package:dashboard/features/anime/animetrace/animetrace_source.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_source_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the per-source user state (enabled flag, custom base URL).
///
/// Enable flags live under each source's own [AnimeTraceSource.spkey]; custom
/// base URLs under `animetrace.source.<climbId>.baseUrl`. Nothing here touches
/// preferences owned by other host features.
class AnimeTraceSourceStore {
  AnimeTraceSourceStore({
    SharedPreferences? preferences,
    List<AnimeTraceSource>? defaults,
  }) : _preferences = preferences,
       _defaults = defaults ?? AnimeTraceSourceCatalog.defaults;

  final SharedPreferences? _preferences;
  final List<AnimeTraceSource> _defaults;

  SharedPreferences? _resolved;

  Future<SharedPreferences> get _prefs async =>
      _resolved ??= _preferences ?? await SharedPreferences.getInstance();

  static String baseUrlKey(String climbId) =>
      'animetrace.source.$climbId.baseUrl';

  /// The catalog with the user's enable flags and custom base URLs applied.
  Future<List<AnimeTraceSource>> loadSources() async {
    final prefs = await _prefs;
    return <AnimeTraceSource>[
      for (final source in _defaults)
        source.copyWith(
          enable: source.discard
              ? false
              : prefs.getBool(source.spkey) ?? source.enable,
          baseUrl: _baseUrlOf(source, prefs) ?? source.baseUrl,
        ),
    ];
  }

  String? _baseUrlOf(AnimeTraceSource source, SharedPreferences prefs) {
    final custom = prefs.getString(baseUrlKey(source.climbId));
    if (custom == null || custom.isEmpty) return null;
    return custom;
  }

  Future<void> setEnabled(AnimeTraceSource source, bool enable) async {
    final prefs = await _prefs;
    await prefs.setBool(source.spkey, enable);
  }

  /// Enables or disables every non-discarded source (the app bar action of the
  /// source list page).
  Future<void> setAllEnabled(
    List<AnimeTraceSource> sources, {
    required bool enable,
  }) async {
    final prefs = await _prefs;
    for (final source in sources) {
      if (source.discard) continue;
      await prefs.setBool(source.spkey, enable);
    }
  }

  Future<void> setCustomBaseUrl(String climbId, String baseUrl) async {
    final prefs = await _prefs;
    final normalized = normalizeBaseUrl(baseUrl);
    if (normalized.isEmpty) {
      await prefs.remove(baseUrlKey(climbId));
    } else {
      await prefs.setString(baseUrlKey(climbId), normalized);
    }
  }

  Future<String?> customBaseUrl(String climbId) async {
    final prefs = await _prefs;
    final value = prefs.getString(baseUrlKey(climbId));
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// `https://host` with no trailing slash — the source app's normalization.
  static String normalizeBaseUrl(String value) {
    var trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }
}
