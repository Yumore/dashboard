import 'package:dashboard/features/reading/easymygo/component/component.dart';
import 'package:dashboard/features/reading/easymygo/component/demo_novel_component.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_source.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_source_factory.dart';

/// Ported from `TestNovelSource` (`lib/plugin/inner/inner_source.dart`).
///
/// Deviation: the original declared `SourceType.manga`; the port declares
/// `novel` so the novel dispatch actually works.
class TestNovelSource extends InnerSource {
  const TestNovelSource();

  @override
  SourceInfo get info => const SourceInfo(
    key: 'test_novel',
    fromPackage: InnerSourceFactory.innerExtensionPackage,
    label: '测试小说源',
    type: SourceType.novel,
    versionName: '1.0',
    versionCode: 1,
    path: 'test_novel',
    loaderType: SourceLoaderType.inner,
    description: '内置测试小说源（离线数据）',
  );

  @override
  List<Component> get components => <Component>[
    DemoNovelComponent(sourceInfo: info),
  ];
}
