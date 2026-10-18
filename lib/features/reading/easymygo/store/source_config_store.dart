import 'dart:convert';

import 'package:dashboard/features/reading/easymygo/entity/source_config_item.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the two settings that drive the source engine.
///
/// EasyMyGo kept the first in a Hive box (`SourceConfigController`, box
/// `source_config`, single key) and the second on the file system (imported
/// `.mygopack` extensions). The host uses `shared_preferences` everywhere, so
/// both live here as JSON strings:
///
/// * `content.easymygo.source_config.v1` — per-source `enabled` / `order`
/// * `content.easymygo.rule_packages.v1` — imported rule package manifests
class SourceConfigStore {
  SourceConfigStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static const String configKey = 'content.easymygo.source_config.v1';
  static const String packageKey = 'content.easymygo.rule_packages.v1';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async =>
      _preferences ??= await SharedPreferences.getInstance();

  Future<void> _pending = Future<void>.value();

  /// Serializes writes so two quick toggles cannot lose an update.
  Future<T> _serialize<T>(Future<T> Function() action) {
    final completer = _pending.then((_) => action());
    _pending = completer.then<void>((_) {}, onError: (_) {});
    return completer;
  }

  Future<List<SourceConfigItem>> readConfigs() async {
    final prefs = await _prefs();
    final raw = prefs.getString(configKey);
    if (raw == null || raw.isEmpty) return <SourceConfigItem>[];
    return decodeConfigs(raw);
  }

  /// Decodes a persisted config list, skipping malformed entries.
  static List<SourceConfigItem> decodeConfigs(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return <SourceConfigItem>[];
    }
    if (decoded is! List) return <SourceConfigItem>[];
    return <SourceConfigItem>[
      for (final entry in decoded)
        if (entry is Map)
          SourceConfigItem.fromJson(<String, Object?>{
            for (final item in entry.entries) '${item.key}': item.value,
          }),
    ];
  }

  static String encodeConfigs(List<SourceConfigItem> items) =>
      jsonEncode(<Object?>[for (final item in items) item.toJson()]);

  Future<void> writeConfigs(List<SourceConfigItem> items) => _serialize(() async {
    final prefs = await _prefs();
    await prefs.setString(configKey, encodeConfigs(items));
  });

  /// Merges the registered sources with the stored config.
  ///
  /// Ported from `SourceConfigController` + `SourceBundle`: a source the user
  /// never touched gets `enabled = true` and `order = 999` (its registration
  /// index breaks ties), a config whose source disappeared is dropped.
  Future<List<SourceConfigItem>> syncConfigs(
    List<SourceInfo> sources, {
    bool persist = true,
  }) async {
    final stored = await readConfigs();
    final byIdentify = <String, SourceConfigItem>{
      for (final item in stored) item.identify: item,
    };
    final merged = <SourceConfigItem>[];
    for (var index = 0; index < sources.length; index++) {
      final identify = sources[index].identify;
      final saved = byIdentify[identify];
      merged.add(
        saved ?? SourceConfigItem(
          key: sources[index].key,
          fromPackage: sources[index].fromPackage,
          order: index,
        ),
      );
    }
    merged.sort((a, b) => a.order.compareTo(b.order));
    if (persist) await writeConfigs(merged);
    return merged;
  }

  Future<SourceConfigItem> save(SourceConfigItem item) => _serialize(() async {
    final items = await readConfigs();
    final next = <SourceConfigItem>[
      for (final existing in items)
        if (existing.identify != item.identify) existing,
      item,
    ];
    final prefs = await _prefs();
    await prefs.setString(configKey, encodeConfigs(next));
    return item;
  });

  Future<List<String>> readPackages() async {
    final prefs = await _prefs();
    return prefs.getStringList(packageKey) ?? <String>[];
  }

  Future<void> writePackages(List<String> manifests) => _serialize(() async {
    final prefs = await _prefs();
    await prefs.setStringList(packageKey, manifests);
  });

  Future<void> addPackage(String manifest) => _serialize(() async {
    final prefs = await _prefs();
    final manifests = prefs.getStringList(packageKey) ?? <String>[];
    if (!manifests.contains(manifest)) manifests.add(manifest);
    await prefs.setStringList(packageKey, manifests);
  });

  Future<void> removePackageAt(int index) => _serialize(() async {
    final prefs = await _prefs();
    final manifests = prefs.getStringList(packageKey) ?? <String>[];
    if (index < 0 || index >= manifests.length) return;
    manifests.removeAt(index);
    await prefs.setStringList(packageKey, manifests);
  });
}
