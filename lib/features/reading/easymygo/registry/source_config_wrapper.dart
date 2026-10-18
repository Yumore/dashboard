import 'package:dashboard/features/reading/easymygo/entity/source_config_item.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';

/// A loaded source paired with its persisted user config.
///
/// Ported from `SourceConfigWrapper` in
/// `lib/plugin/source/controller/source_controller.dart` (EasyMyGo).
class SourceConfigWrapper {
  const SourceConfigWrapper({required this.config, required this.source});

  final SourceConfigItem config;
  final SourceData source;

  SourceInfo get info => source.source;

  String get identify => config.identify;

  SourceConfigWrapper copyWith({SourceConfigItem? config, SourceData? source}) =>
      SourceConfigWrapper(
        config: config ?? this.config,
        source: source ?? this.source,
      );
}
