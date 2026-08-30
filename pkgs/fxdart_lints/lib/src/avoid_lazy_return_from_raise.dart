import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'ast.dart';

class AvoidLazyReturnFromRaise extends DartLintRule {
  AvoidLazyReturnFromRaise() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_lazy_return_from_raise',
    problemMessage:
        'Never return a lazy pipeline from a raise block — it leaks as '
        'RaiseLeakedError at a distant toList(). Materialize with toList(), '
        'sequence(), or mapOrAccumulate() inside the block.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addReturnStatement((node) {
      if (enclosingNamedCallback(node, raiseBuilders) == null) return;
      final expr = node.expression;
      if (expr == null) return;
      if (!isFxChain(expr)) return;
      final last = lastMethodName(expr);
      if (last != null && chainTerminals.contains(last)) return;
      reporter.atNode(node, _code);
    });
  }
}
