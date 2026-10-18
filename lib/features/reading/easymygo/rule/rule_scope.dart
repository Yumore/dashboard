import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_buffer.dart';

/// The per-call evaluation scope handed to every [SourceAction].
///
/// Ported from `SourceUtilsScope` (`lib/plugin/source/utils/source_utils_scope.dart`),
/// which held the per-source buffer on `SourceInfo` via an `Expando`. Because the
/// port evaluates rules in Dart instead of JS there is no cross-call buffer to
/// share, so each component call builds a fresh scope.
class RuleScope {
  RuleScope({
    required this.sourceInfo,
    this.baseUrl = '',
    Map<String, String>? variables,
  }) : variables = <String, String>{
         'baseUrl': baseUrl,
         'source': sourceInfo.identify,
         ...?variables,
       };

  final SourceInfo sourceInfo;
  final String baseUrl;
  final Map<String, String> variables;
  final RuleBuffer buffer = RuleBuffer();

  void set(String name, String value) {
    variables[name] = value;
  }

  String? get(String name) => variables[name];
}
