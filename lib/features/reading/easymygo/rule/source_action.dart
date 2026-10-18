import 'package:dashboard/features/reading/easymygo/rule/buffer_action.dart';
import 'package:dashboard/features/reading/easymygo/rule/html_selector_action.dart';
import 'package:dashboard/features/reading/easymygo/rule/html_xpath_action.dart';
import 'package:dashboard/features/reading/easymygo/rule/json_path_action.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_scope.dart';

/// Ported from `SourceAction` (`lib/plugin/source/utils/action/source_action.dart`).
///
/// In EasyMyGo a source author wrote JavaScript such as
/// `HtmlQuerySelector(html, '.title').text()` and the class/funcName pair was
/// dispatched through this registry. The port has no JS runtime, so the same
/// (clazz, constructorArgs, funcName, args) shape is declared in Dart and
/// evaluated directly — the rule model itself is unchanged.
///
/// The original also registered a `WebView` action backed by the platform
/// webview; that one is intentionally not carried over (it needs a live
/// platform view and cannot be evaluated headlessly).
abstract class SourceAction {
  const SourceAction();

  static final List<SourceAction> actions = <SourceAction>[
    BufferAction(),
    HtmlSelectorAction(),
    HtmlXpathAction(),
    JsonPathAction(),
  ];

  static SourceAction of(String clazz) {
    for (final action in actions) {
      if (action.clazz == clazz) {
        return action;
      }
    }
    throw RuleException('未找到动作类型: $clazz');
  }

  String get clazz;

  int get constructorArgsCount;

  List<String> get funcNames;

  String execute(
    RuleScope scope,
    String funcName,
    List<String> constructorArgs,
    List<String> args,
  );
}
