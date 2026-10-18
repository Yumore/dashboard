import 'package:dashboard/features/reading/easymygo/entity/source_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_source_loader.dart';
import 'package:dashboard/features/reading/easymygo/source/rule_source_loader.dart';

/// Ported from `SourceLoader` (`lib/plugin/source/loader/source_loader.dart`).
///
/// In EasyMyGo the loaders were async because they read files; here a descriptor
/// is supplied as text, so parsing is synchronous. The two-step contract
/// ([parse] then [load]) is preserved because the app wires sources in that
/// order: discover metadata, then instantiate components.
abstract class SourceLoader {
  const SourceLoader();

  static final List<SourceLoader> loaders = <SourceLoader>[
    RuleSourceLoader(),
    InnerSourceLoader(),
  ];

  static SourceLoader? of(SourceLoaderType type) {
    for (final loader in loaders) {
      if (loader.type == type) return loader;
    }
    return null;
  }

  SourceLoaderType get type;

  /// Reads a source descriptor and registers it for [load].
  ///
  /// Returns `null` when the descriptor does not describe a source this loader
  /// understands — the original returned `null` for an unparsable JS header.
  SourceInfo? parse(String fromExtension, String raw);

  SourceData load(SourceInfo sourceInfo);
}
