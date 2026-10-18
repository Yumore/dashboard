import 'package:dashboard/features/reading/easymygo/component/component.dart';
import 'package:dashboard/features/reading/easymygo/component/demo_manga_component.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_source.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_source_factory.dart';

/// Ported from `TestMangaSource` (`lib/plugin/inner/inner_source.dart`).
class TestMangaSource extends InnerSource {
  const TestMangaSource();

  @override
  SourceInfo get info => const SourceInfo(
    key: 'test_manga',
    fromPackage: InnerSourceFactory.innerExtensionPackage,
    label: '测试漫画源',
    type: SourceType.manga,
    versionName: '1.0',
    versionCode: 1,
    path: 'test_manga',
    loaderType: SourceLoaderType.inner,
    description: '内置测试漫画源（离线数据）',
  );

  @override
  List<Component> get components => <Component>[
    DemoMangaComponent(sourceInfo: info),
  ];
}
