import 'package:dashboard/features/reading/easymygo/entity/source_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_source_factory.dart';
import 'package:dashboard/features/reading/easymygo/source/source_loader.dart';

/// Ported from `InnerSourceLoader` (`lib/plugin/source/loader/inner/`).
///
/// The original read its key from `SourceInfo.path`; when the path is empty the
/// port falls back to the key so a hand-built [SourceInfo] still loads.
class InnerSourceLoader extends SourceLoader {
  const InnerSourceLoader();

  @override
  SourceLoaderType get type => SourceLoaderType.inner;

  @override
  SourceInfo? parse(String fromExtension, String raw) {
    final inner = InnerSourceFactory.of(raw.trim());
    if (inner == null) return null;
    return inner.info.copyWith(
      fromPackage: fromExtension.isEmpty
          ? inner.info.fromPackage
          : fromExtension,
    );
  }

  @override
  SourceData load(SourceInfo sourceInfo) {
    final key = sourceInfo.path.isEmpty ? sourceInfo.key : sourceInfo.path;
    final inner = InnerSourceFactory.of(key);
    if (inner == null) {
      return SourceData(
        source: sourceInfo,
        components: const <Object>[],
        state: SourceState.error,
        errorMsg: '内置源不存在: $key',
      );
    }
    return SourceData(
      source: sourceInfo,
      components: <Object>[...inner.components],
    );
  }
}
