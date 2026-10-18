import 'package:dashboard/features/reading/easymygo/component/rule_source_component.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_definition_parser.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_engine.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_source_definition.dart';
import 'package:dashboard/features/reading/easymygo/source/source_loader.dart';

/// Ported from `JsSourceLoader` (`lib/plugin/source/loader/js/js_source_loader.dart`).
///
/// EasyMyGo read a JS file, evaluated it with `flutter_js` and kept the wrappers
/// whose `isAvailable()` said the source implemented them. The host has no JS
/// runtime, so a rule source arrives as a JSON descriptor (the same information
/// the JS metadata header plus function bodies carried), is parsed by
/// [RuleDefinitionParser] and instantiated as a [RuleSourceComponent] — one per
/// source, implementing whichever businesses the descriptor declares.
///
/// [parse] registers the descriptor; [load] instantiates it. That two-step flow
/// mirrors the original's "discover then load" extension bootstrap.
class RuleSourceLoader extends SourceLoader {
  RuleSourceLoader({RuleEngine Function()? engineFactory})
    : _engineFactory = engineFactory ?? RuleEngine.new;

  /// Shared registry used by the app wiring. Tests build their own instance so
  /// they can inject a fake HTTP client.
  static final RuleSourceLoader instance = RuleSourceLoader();

  final RuleEngine Function() _engineFactory;
  final RuleDefinitionParser _parser = const RuleDefinitionParser();
  final Map<String, RuleSourceDefinition> _definitions =
      <String, RuleSourceDefinition>{};

  @override
  SourceLoaderType get type => SourceLoaderType.rule;

  List<String> get registeredIdentifies => _definitions.keys.toList();

  RuleSourceDefinition? definitionOf(String identify) => _definitions[identify];

  @override
  SourceInfo? parse(String fromExtension, String raw) =>
      parseDefinition(fromExtension, _parser.parseString(raw));

  /// Registers an already-decoded descriptor (used by extension packages).
  SourceInfo parseDefinition(String fromExtension, Object? json) {
    final definition = _parser.parse(json);
    final info = definition.info.copyWith(
      fromPackage: fromExtension.isEmpty
          ? definition.info.fromPackage
          : fromExtension,
      loaderType: SourceLoaderType.rule,
    );
    _definitions[info.identify] = definition.withInfo(info);
    return info;
  }

  @override
  SourceData load(SourceInfo sourceInfo) {
    final definition = _definitions[sourceInfo.identify];
    if (definition == null) {
      return SourceData(
        source: sourceInfo,
        components: const <Object>[],
        state: SourceState.error,
        errorMsg: '书源未注册: ${sourceInfo.identify}',
      );
    }
    try {
      final component = RuleSourceComponent(
        sourceInfo: sourceInfo,
        definition: definition,
        engine: _engineFactory(),
      );
      return SourceData(
        source: sourceInfo,
        components: <Object>[component],
      );
    } catch (error) {
      return SourceData(
        source: sourceInfo,
        components: const <Object>[],
        state: SourceState.error,
        errorMsg: '$error',
      );
    }
  }
}
