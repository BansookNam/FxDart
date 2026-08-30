import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:fxdart_lints/src/ast.dart';
import 'package:test/test.dart';

void main() {
  group('enclosingNamedCallback', () {
    test('matches a return from the raise callback', () {
      final returns = collect<ReturnStatement>(
        parse('''
f() => either((r) {
  return fx([1, 2, 3]).map((n) => n);
});
'''),
      );
      expect(returns, hasLength(1));
      expect(enclosingNamedCallback(returns.single, raiseBuilders), isNotNull);
    });

    test('does not match a return from a nested map callback', () {
      final returns = collect<ReturnStatement>(
        parse('''
f() => either((r) {
  return fx([1, 2, 3]).map((n) {
    return fx([n]).map((m) => m * 2);
  }).toList();
});
'''),
      );
      final inner = returns.singleWhere(
        (r) => !r.toSource().contains('toList'),
      );
      final outer = returns.singleWhere((r) => r.toSource().contains('toList'));
      expect(enclosingNamedCallback(inner, raiseBuilders), isNull);
      expect(enclosingNamedCallback(outer, raiseBuilders), isNotNull);
      expect(ancestorNamedCallback(inner, raiseBuilders), isNotNull);
    });

    test('matches an arrow-body raise callback from its expression', () {
      final bodies = collect<ExpressionFunctionBody>(
        parse('''
f() => either((r) => fx([1, 2, 3]).map((n) => n));
'''),
      );
      final raise = bodies.singleWhere(
        (b) => b.expression.toSource().startsWith('fx('),
      );
      expect(
        enclosingNamedCallback(raise.expression, raiseBuilders),
        isNotNull,
      );
      final inner = bodies.singleWhere((b) => b.expression.toSource() == 'n');
      expect(enclosingNamedCallback(inner.expression, raiseBuilders), isNull);
    });
  });

  group('chainRootName / isFxChain', () {
    test('fxEvents(...).attempt().retryOnError() is an fx chain', () {
      final retry = invocation(
        parse(
          'f() => fxEvents(s).attempt((e, st) => e.toString()).retryOnError();',
        ),
        'retryOnError',
      );
      expect(isFxChain(retry), isTrue);
      expect(chainRootName(retry), 'fxEvents');
      expect(targetChainContains(retry, 'attempt'), isTrue);
    });

    test('Http().attempt().retryOnError() is not an fx chain', () {
      final retry = invocation(
        parse('''
class Http {
  Http attempt() => this;
  Http retryOnError() => this;
}
f() => Http().attempt().retryOnError();
'''),
        'retryOnError',
      );
      expect(isFxChain(retry), isFalse);
      expect(targetChainContains(retry, 'attempt'), isTrue);
    });
  });

  group('lastMethodName', () {
    test('map is last on a lazy fx(...).map(...)', () {
      final expr = arrowOf(parse('f() => fx([1, 2, 3]).map((n) => n);'));
      expect(lastMethodName(expr), 'map');
      expect(isFxChain(expr), isTrue);
    });

    test('toList is last on a materialized chain', () {
      final expr = arrowOf(
        parse('f() => fx([1, 2, 3]).map((n) => n).toList();'),
      );
      expect(lastMethodName(expr), 'toList');
    });

    test('fx is last on a bare fx(...)', () {
      final expr = arrowOf(parse('f() => fx([1, 2, 3]);'));
      expect(lastMethodName(expr), 'fx');
    });
  });
}

CompilationUnit parse(String source) {
  return parseString(
    content: source,
    featureSet: FeatureSet.latestLanguageVersion(),
  ).unit;
}

List<T> collect<T extends AstNode>(AstNode root) {
  final out = <T>[];
  root.accept(_Collect<T>(out));
  return out;
}

MethodInvocation invocation(CompilationUnit unit, String name) {
  return collect<MethodInvocation>(
    unit,
  ).singleWhere((m) => m.methodName.name == name);
}

Expression arrowOf(CompilationUnit unit) {
  final fn = unit.declarations.whereType<FunctionDeclaration>().single;
  return (fn.functionExpression.body as ExpressionFunctionBody).expression;
}

class _Collect<T extends AstNode> extends GeneralizingAstVisitor<void> {
  _Collect(this.out);
  final List<T> out;

  @override
  void visitNode(AstNode node) {
    if (node is T) out.add(node);
    super.visitNode(node);
  }
}
