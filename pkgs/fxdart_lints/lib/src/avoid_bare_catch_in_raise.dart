import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'ast.dart';

class AvoidBareCatchInRaise extends DartLintRule {
  AvoidBareCatchInRaise() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_bare_catch_in_raise',
    problemMessage:
        'A bare catch inside either/nullable/foldRaise swallows the '
        'raise signal. Use catching(...) / eitherCatching, or `on Exception` '
        '(the signal is an Error).',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCatchClause((node) {
      if (ancestorNamedCallback(node, raiseBuilders) == null) return;
      if (!_swallowsRaiseSignal(node)) return;
      reporter.atNode(node, _code);
    });
  }

  /// The raise signal is an [Error]. Bare catch / `on Object` / `on Error` /
  /// `on dynamic` swallow it. `on Exception` and specific subtypes
  /// (`on FormatException`) do not.
  bool _swallowsRaiseSignal(CatchClause node) {
    final type = node.exceptionType;
    if (type == null) return true;
    if (type is NamedType) {
      final name = type.name.lexeme;
      return name == 'Object' || name == 'Error' || name == 'dynamic';
    }
    return false;
  }
}
