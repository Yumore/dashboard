import 'dart:convert';

import 'package:dashboard/features/live/easy_tv_live/easy_tv_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the subscription list (`subscribe` in the source app).
class EasyTvSourceStore {
  const EasyTvSourceStore({SharedPreferences? preferences})
    : _preferences = preferences;

  final SharedPreferences? _preferences;

  static const storageKey = 'easy_tv_live_sources';

  Future<SharedPreferences> _prefs() async =>
      _preferences ?? SharedPreferences.getInstance();

  Future<List<EasyTvSource>> load() async {
    final raw = (await _prefs()).getString(storageKey);
    if (raw == null || raw.isEmpty) return <EasyTvSource>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <EasyTvSource>[];
    return <EasyTvSource>[
      for (final item in decoded)
        if (item is Map<String, dynamic>) EasyTvSource.fromJson(item),
    ];
  }

  Future<void> save(List<EasyTvSource> sources) async {
    await (await _prefs()).setString(
      storageKey,
      jsonEncode(<Map<String, dynamic>>[
        for (final source in sources) source.toJson(),
      ]),
    );
  }

  /// Returns the selected source, else the first one, else a selected default.
  static EasyTvSource selectedOrDefault(List<EasyTvSource> sources) {
    for (final source in sources) {
      if (source.selected) return source;
    }
    if (sources.isNotEmpty) return sources.first;
    return const EasyTvSource(link: EasyTvSource.defaultLink, selected: true);
  }

  /// Marks exactly one source selected; unknown links fall back to the first.
  static List<EasyTvSource> select(List<EasyTvSource> sources, String link) {
    if (sources.isEmpty) {
      return <EasyTvSource>[EasyTvSource(link: link, selected: true)];
    }
    return <EasyTvSource>[
      for (final source in sources)
        source.copyWith(selected: source.link == link),
    ];
  }

  /// Adds a source unless the link already exists, then selects it.
  static List<EasyTvSource> add(
    List<EasyTvSource> sources,
    EasyTvSource source,
  ) {
    final duplicate = sources.any((item) => item.link == source.link);
    final base = duplicate ? sources : <EasyTvSource>[...sources, source];
    return select(base, source.link);
  }

  /// Removes a source, selecting the first survivor (or the default).
  static List<EasyTvSource> remove(List<EasyTvSource> sources, String link) {
    final remaining = <EasyTvSource>[
      for (final source in sources)
        if (source.link != link) source,
    ];
    if (remaining.isEmpty) {
      return <EasyTvSource>[
        const EasyTvSource(link: EasyTvSource.defaultLink, selected: true),
      ];
    }
    if (remaining.any((source) => source.selected)) return remaining;
    return select(remaining, remaining.first.link);
  }
}
