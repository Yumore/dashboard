import 'package:dashboard/features/reading/easymygo/entity/extension_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_data.dart';

/// 扩展包加载状态，对应 EasyMyGo `ExtensionLoadStateType`。
enum ExtensionLoadState {
  loaded,
  error;

  static ExtensionLoadState fromName(String? name) {
    for (final value in ExtensionLoadState.values) {
      if (value.name == name) return value;
    }
    return ExtensionLoadState.error;
  }
}

/// 扩展包 + 其注入的源列表，对应 EasyMyGo `ExtensionData`。
class ExtensionData {
  const ExtensionData({
    required this.info,
    this.sources = const <SourceData>[],
    this.state = ExtensionLoadState.loaded,
    this.errorMsg = '',
    this.folderPath = '',
  });

  final ExtensionInfo info;
  final List<SourceData> sources;
  final ExtensionLoadState state;
  final String errorMsg;
  final String folderPath;

  bool get isError => state == ExtensionLoadState.error;

  List<SourceData> get mangaSources =>
      sources.where((e) => e.source.type.name == 'manga').toList();

  List<SourceData> get novelSources =>
      sources.where((e) => e.source.type.name == 'novel').toList();
}
