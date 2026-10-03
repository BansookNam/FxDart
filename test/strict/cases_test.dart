import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('cases', () {
    test('should work in pipe', () {
      final res = fx([10, 20, 30])
          .map(
            fxCases<int, int>([
              ((n) => fxGt(15, n), (n) => n + 20),
              ((n) => fxGt(25, n), (n) => n + 10),
            ]),
          )
          .toList();
      expect(res, equals([30, 30, 30]));
    });

    test('should work with type-narrowing predicates', () {
      final res =
          fx([
                {'a': 'A', 'b': 'B'},
                {'a': 'A'},
              ])
              .map(
                fxCases<Map<String, String>, String>([
                  ((n) => n.containsKey('b'), (n) => n['b']!),
                ], orElse: (n) => n['a']!),
              )
              .toList();
      expect(res, equals(['B', 'A']));

      final upper = fxCases<Object, String>([
        (fxIsString, (s) => (s as String).toUpperCase()),
      ], orElse: (_) => 'not string');
      expect(upper('hello'), equals('HELLO'));
      expect(upper(123), equals('not string'));
    });

    test('should match first predicate', () {
      final res = fx([5, -5])
          .map(
            fxCases<int, Object>([((n) => fxLt(0, n), fxAlways('positive'))]),
          )
          .toList();
      expect(res, equals(['positive', -5]));
    });

    test(
      'should throw when no case matches, no orElse, and value is not R',
      () {
        final f = fxCases<int, String>([((n) => n < 0, (n) => 'negative')]);
        expect(() => f(1), throwsStateError);
      },
    );
  });
}
