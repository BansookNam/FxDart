import 'package:analyzer/dart/ast/ast.dart';

/// Names of fxdart builders whose callback is a raise scope.
const raiseBuilders = {
  'either',
  'eitherAsync',
  'eitherCatching',
  'eitherCatchingAsync',
  'nullable',
  'nullableAsync',
  'foldRaise',
  'foldRaiseAsync',
};

/// Terminals that materialize a chain. Returning one of these from a raise
/// block is the sanctioned escape; returning a lazy operator is not.
const chainTerminals = {
  'toList',
  'fold',
  'reduce',
  'each',
  'forEach',
  'consume',
  'sequence',
  'mapOrAccumulate',
  'flattenOrAccumulate',
  'rights',
  'lefts',
  'separated',
  'groupBy',
  'countBy',
  'indexBy',
  'sum',
  'sumBy',
  'average',
  'averageBy',
  'find',
  'head',
  'last',
  'nth',
  'size',
  'join',
  'every',
  'some',
  'any',
  'first',
  'single',
  'toSet',
  'toMap',
  'countWhere',
  'min',
  'max',
  'minBy',
  'maxBy',
};

const chainRoots = {'fx', 'fxAsync', 'fxStream', 'fxEvents'};

const chainRootGetters = {'fx', 'fxAsync', 'fxEvents', 'fxLive'};

/// Walks [node] up looking for a function expression that is the first
/// argument of a call named in [names].
FunctionExpression? enclosingNamedCallback(AstNode node, Set<String> names) {
  AstNode? current = node;
  while (current != null) {
    if (current is FunctionExpression) {
      final argList = current.parent;
      final call = argList is ArgumentList ? argList.parent : null;
      if (call is MethodInvocation && names.contains(call.methodName.name)) {
        return current;
      }
      if (call is FunctionExpressionInvocation) {
        final fn = call.function;
        if (fn is SimpleIdentifier && names.contains(fn.name)) {
          return current;
        }
      }
    }
    current = current.parent;
  }
  return null;
}

/// The innermost method name of [expression], walking through
/// `toList`/`where` wrappers so `ids.map(f).toList()` still looks like `map`.
String? innermostMethodName(Expression expression) {
  Expression current = expression;
  while (true) {
    if (current is MethodInvocation) {
      final name = current.methodName.name;
      if (name == 'toList' || name == 'cast' || name == 'where') {
        final target = current.target;
        if (target == null) return name;
        current = target;
        continue;
      }
      return name;
    }
    if (current is ParenthesizedExpression) {
      current = current.expression;
      continue;
    }
    return null;
  }
}

/// Whether [expression] is `something.map(...)`, possibly wrapped in
/// `.toList()` / `.cast()`.
bool isMappedIterable(Expression expression) {
  return innermostMethodName(expression) == 'map';
}

bool isForElementList(Expression expression) {
  final e = expression is ParenthesizedExpression
      ? expression.expression
      : expression;
  return e is ListLiteral && e.elements.any((el) => el is ForElement);
}

/// Root identifier of a call chain (`fx`, `.fx`, …).
String? chainRootName(Expression expression) {
  Expression? current = expression;
  while (current != null) {
    if (current is MethodInvocation) {
      if (current.target == null) return current.methodName.name;
      current = current.target;
      continue;
    }
    if (current is PropertyAccess) {
      if (chainRootGetters.contains(current.propertyName.name) &&
          current.target is! MethodInvocation &&
          current.target is! PropertyAccess) {
        return current.propertyName.name;
      }
      current = current.target;
      continue;
    }
    if (current is PrefixedIdentifier) {
      if (chainRootGetters.contains(current.identifier.name)) {
        return current.identifier.name;
      }
      return current.identifier.name;
    }
    if (current is SimpleIdentifier) return current.name;
    if (current is FunctionExpressionInvocation) {
      final fn = current.function;
      if (fn is SimpleIdentifier) return fn.name;
      current = fn;
      continue;
    }
    if (current is ParenthesizedExpression) {
      current = current.expression;
      continue;
    }
    return null;
  }
  return null;
}

bool isFxChain(Expression expression) {
  final root = chainRootName(expression);
  return root != null &&
      (chainRoots.contains(root) || chainRootGetters.contains(root));
}

/// Last method in a chain: `fx(xs).map(f).filter(g)` → `filter`.
/// `fx(xs)` with no further methods → `fx`.
String? lastMethodName(Expression expression) {
  final e = expression is ParenthesizedExpression
      ? expression.expression
      : expression;
  if (e is MethodInvocation) return e.methodName.name;
  if (e is PropertyAccess) return e.propertyName.name;
  return null;
}

/// Walks the target of [invocation] looking for a method named [name].
bool targetChainContains(MethodInvocation invocation, String name) {
  Expression? current = invocation.target;
  while (current != null) {
    if (current is MethodInvocation) {
      if (current.methodName.name == name) return true;
      current = current.target;
      continue;
    }
    if (current is PropertyAccess) {
      current = current.target;
      continue;
    }
    if (current is ParenthesizedExpression) {
      current = current.expression;
      continue;
    }
    return false;
  }
  return false;
}
