import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';

/// 源加载状态，对应 EasyMyGo `SourceLoadStateType`。
enum SourceState {
  loaded,
  error;

  static SourceState fromName(String? name) {
    for (final value in SourceState.values) {
      if (value.name == name) return value;
    }
    return SourceState.error;
  }
}

/// 源 + 组件列表 + 加载状态，对应 EasyMyGo `SourceBundle` 单条 `SourceData`。
class SourceData {
  const SourceData({
    required this.source,
    required this.components,
    this.state = SourceState.loaded,
    this.errorMsg = '',
  });

  final SourceInfo source;
  final List<Object> components;
  final SourceState state;
  final String errorMsg;

  bool get isError => state == SourceState.error;

  SourceData copyWith({
    SourceInfo? source,
    List<Object>? components,
    SourceState? state,
    String? errorMsg,
  }) {
    return SourceData(
      source: source ?? this.source,
      components: components ?? this.components,
      state: state ?? this.state,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}
