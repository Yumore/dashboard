import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';

/// Ported from `Component` (`lib/plugin/component/api/component.dart`).
///
/// Every EasyMyGo business interface extended this and carried the owning
/// [SourceInfo], which is how the source bundle dispatched a call to the right
/// plugin instance.
abstract class Component {
  const Component(this.sourceInfo);

  final SourceInfo sourceInfo;
}
