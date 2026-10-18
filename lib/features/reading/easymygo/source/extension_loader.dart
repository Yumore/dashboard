import 'package:dashboard/features/reading/easymygo/entity/extension_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/extension_info.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_extension_loader.dart';
import 'package:dashboard/features/reading/easymygo/source/rule_extension_loader.dart';

/// Ported from `ExtensionLoader` (`lib/plugin/extension/loader/`).
///
/// EasyMyGo had three: `js` (unimplemented stub), `mygopack` (zip archive) and
/// `inner`. The host has no archive dependency, so the port keeps two slots: the
/// `js` slot now carries rule-source packages as a JSON manifest (the JS
/// substitution) and `inner` is unchanged. `mygopack` is deliberately absent —
/// see the module report.
abstract class ExtensionLoader {
  const ExtensionLoader();

  /// Ported from `ExtensionLoader.libVersionMin` / `libVersionMax`.
  static const int libVersionMin = 1;
  static const int libVersionMax = 1;

  static final List<ExtensionLoader> loaders = <ExtensionLoader>[
    RuleExtensionLoader(),
    InnerExtensionLoader(),
  ];

  static ExtensionLoader? of(ExtensionLoaderType type) {
    for (final loader in loaders) {
      if (loader.type == type) return loader;
    }
    return null;
  }

  static ExtensionLoader? ofName(String name) {
    for (final loader in loaders) {
      if (loader.type.name == name) return loader;
    }
    return null;
  }

  ExtensionLoaderType get type;

  /// Parses an extension manifest and registers it for [load].
  ExtensionInfo? parse(String raw);

  ExtensionData load(ExtensionInfo info);
}
