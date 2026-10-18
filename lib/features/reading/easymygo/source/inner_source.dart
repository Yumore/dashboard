import 'package:dashboard/features/reading/easymygo/component/component.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';

/// Ported from `InnerSource` (`lib/plugin/inner/inner_source.dart`).
///
/// An inner source ships inside the app: no file, no descriptor, just Dart
/// components. The original exposed `getComponentList(SourceInfo)`; because the
/// port's components carry their own [SourceInfo] the source hands the list out
/// directly.
abstract class InnerSource {
  const InnerSource();

  SourceInfo get info;

  SourceType get type => info.type;

  List<Component> get components;
}
