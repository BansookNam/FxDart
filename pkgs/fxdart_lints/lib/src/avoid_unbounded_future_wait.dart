import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'ast.dart';

class AvoidUnboundedFutureWait extends DartLintRule {
  AvoidUnboundedFutureWait() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_unbounded_future_wait',
    problemMessage:
        "Don't use Future.wait on a mapped fetch — it is unbounded. "
        'Use fx(ids).toAsync().map(fetch).concurrent(n).toList() '
        '(or .mapConcurrent(n, fetch)).',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'wait') return;
      if (!_isFutureWait(node)) return;
      if (node.argumentList.arguments.isEmpty) return;
      final first = node.argumentList.arguments.first;
      final expr = first is NamedExpression ? first.expression : first;
      if (isMappedIterable(expr) || isForElementList(expr)) {
        reporter.atNode(node.methodName, _code);
      }
    });
  }

  bool _isFutureWait(MethodInvocation node) {
    final target = node.target;
    if (target is SimpleIdentifier) return target.name == 'Future';
    if (target is PrefixedIdentifier) {
      return target.identifier.name == 'Future';
    }
    return false;
  }
}
