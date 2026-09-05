import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/error/listener.dart';

import 'ast.dart';

class AttemptAfterRetry extends DartLintRule {
  AttemptAfterRetry() : super(code: _code);

  static const _code = LintCode(
    name: 'attempt_after_retry',
    problemMessage:
        'attempt() after retryOn() / retryOnError(), never before. '
        'Those operators watch the error channel; a Left is not an error event.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      final name = node.methodName.name;
      if (name != 'retryOn' && name != 'retryOnError') return;
      if (!isFxChain(node)) return;
      if (targetChainContains(node, 'attempt')) {
        reporter.atNode(node.methodName, _code);
      }
    });
  }
}
