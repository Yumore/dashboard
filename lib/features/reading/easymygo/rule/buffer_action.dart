import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_scope.dart';
import 'package:dashboard/features/reading/easymygo/rule/source_action.dart';

/// Ported from `BufferAction` — `Buffer.put(value)` / `Buffer.get(key)`.
class BufferAction extends SourceAction {
  const BufferAction();

  @override
  String get clazz => 'Buffer';

  @override
  int get constructorArgsCount => 0;

  @override
  List<String> get funcNames => const <String>['put', 'get'];

  @override
  String execute(
    RuleScope scope,
    String funcName,
    List<String> constructorArgs,
    List<String> args,
  ) {
    final value = args.isNotEmpty ? args.first : '';
    switch (funcName) {
      case 'put':
        return scope.buffer.put(value);
      case 'get':
        return scope.buffer.get(value) ?? '';
    }
    throw RuleException('Buffer 不支持 $funcName');
  }
}
