import 'package:dashboard/features/reading/easymygo/component/component.dart';
import 'package:dashboard/features/reading/easymygo/entity/extension_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_source.dart';
import 'package:dashboard/features/reading/easymygo/source/test_manga_source.dart';
import 'package:dashboard/features/reading/easymygo/source/test_novel_source.dart';

/// Ported from `InnerSourceFactory` (`lib/plugin/inner/inner_source.dart`).
///
/// The inner extension is always present and always first in the extension list;
/// it is the offline source set the host app ships.
class InnerSourceFactory {
  const InnerSourceFactory._();

  static const String innerExtensionPackage =
      'com.heyanle.easymygo.extension.inner';

  static const ExtensionInfo innerExtensionInfo = ExtensionInfo(
    fromPackage: innerExtensionPackage,
    label: '内置源',
    versionName: '1.0',
    versionCode: 1,
    libVersion: 1,
    loadType: ExtensionLoaderType.inner,
    readme: '纯纯 Mygo 内置源',
    sources: <SourceType>[SourceType.manga, SourceType.novel],
  );

  static const List<InnerSource> sources = <InnerSource>[
    TestMangaSource(),
    TestNovelSource(),
  ];

  static List<String> get keys => <String>[
    for (final source in sources) source.info.key,
  ];

  static InnerSource? of(String key) {
    for (final source in sources) {
      if (source.info.key == key) return source;
    }
    return null;
  }

  /// Every component the inner sources provide, used by tests and diagnostics.
  static List<Component> get components => <Component>[
    for (final source in sources) ...source.components,
  ];
}
