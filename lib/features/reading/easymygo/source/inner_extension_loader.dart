import 'package:dashboard/features/reading/easymygo/entity/extension_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/extension_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/source/extension_loader.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_source_factory.dart';
import 'package:dashboard/features/reading/easymygo/source/source_loader.dart';

/// Ported from `InnerExtensionLoader` (`lib/plugin/extension/loader/inner/`).
///
/// The original returned an error when asked to load anything but the inner
/// extension package; the port keeps that guard and otherwise builds one
/// [SourceData] per registered [InnerSource].
class InnerExtensionLoader extends ExtensionLoader {
  const InnerExtensionLoader();

  @override
  ExtensionLoaderType get type => ExtensionLoaderType.inner;

  @override
  ExtensionInfo? parse(String raw) =>
      raw.trim() == InnerSourceFactory.innerExtensionPackage
      ? InnerSourceFactory.innerExtensionInfo
      : null;

  @override
  ExtensionData load(ExtensionInfo info) {
    if (info.fromPackage != InnerSourceFactory.innerExtensionPackage) {
      return ExtensionData(
        info: info,
        state: ExtensionLoadState.error,
        errorMsg: '内置插件非法加载',
      );
    }
    final sourceLoader = SourceLoader.of(SourceLoaderType.inner);
    if (sourceLoader == null) {
      return ExtensionData(
        info: info,
        state: ExtensionLoadState.error,
        errorMsg: '内置插件非法加载',
      );
    }
    final sources = <SourceData>[];
    for (final key in InnerSourceFactory.keys) {
      final sourceInfo = sourceLoader.parse(info.fromPackage, key);
      if (sourceInfo == null) continue;
      sources.add(sourceLoader.load(sourceInfo));
    }
    return ExtensionData(info: info, sources: sources);
  }
}
