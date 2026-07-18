import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

Object? add1(Object? a) => (a as int) + 1;
Object? add1String(Object? a) => ((a as int) + 1).toString();

void main() {
  group('evolve', () {
    test('should return the transformed object', () {
      final obj = {'a': 1, 'b': 2, 'c': 3};
      final transformation = {
        'a': add1String,
        'b': add1,
        'c': add1String,
      };
      final res = evolve(transformation, obj);
      expect(res, equals({'a': '2', 'b': 3, 'c': '4'}));
    });

    test(
        'should apply the `identity` function to a property if there is no matched transform function',
        () {
      final obj = {'a': 1, 'b': 2, 'c': 3};
      final transformation = {'b': add1};
      final res = evolve(transformation, obj);
      expect(res, equals({'a': 1, 'b': 3, 'c': 3}));
    });

    test('should be able to be used in the pipeline', () {
      final obj = {'a': 1, 'b': 2, 'c': 3};
      final transformation = {
        'a': add1String,
        'b': add1,
        'c': add1String,
      };
      final res = evolve(transformation, obj).values.toList();
      expect(res, equals(['2', 3, '4']));
    });

    test('should be handled nested objects', () {
      final obj = {
        'a': 1,
        'b': 2,
        'c': {'d': 3, 'e': 4},
        'f': true,
      };
      final transformation = {
        'a': add1String,
        'b': add1String,
        'c': (Object? o) => evolve(
            {'d': add1String, 'e': add1String}, o as Map<String, Object?>),
      };
      final res = evolve(transformation, obj);
      expect(
          res,
          equals({
            'a': '2',
            'b': '3',
            'c': {'d': '4', 'e': '5'},
            'f': true,
          }));
    });
  });
}
