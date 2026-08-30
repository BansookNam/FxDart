import 'package:analyzer/dart/ast/ast.dart';
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
      _maybeReport(node, node.expression, reporter);
    });
    context.registry.addExpressionFunctionBody((node) {
      _maybeReport(node.expression, node.expression, reporter);
    });
  }

  void _maybeReport(AstNode at, Expression? expr, DiagnosticReporter reporter) {
    if (enclosingNamedCallback(at, raiseBuilders) == null) return;
    if (expr == null) return;
    if (!isFxChain(expr)) return;
    final last = lastMethodName(expr);
    if (last != null && chainTerminals.contains(last)) return;
    reporter.atNode(at, _code);
  }
}
