import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/attempt_after_retry.dart';
import 'src/avoid_bare_catch_in_raise.dart';
import 'src/avoid_lazy_return_from_raise.dart';
import 'src/avoid_unbounded_future_wait.dart';

/// Entry point `custom_lint` looks up.
PluginBase createPlugin() => _FxDartLints();

class _FxDartLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    AvoidUnboundedFutureWait(),
    AvoidBareCatchInRaise(),
    AvoidLazyReturnFromRaise(),
    AttemptAfterRetry(),
  ];
}
