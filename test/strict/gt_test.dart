import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('gt(greater than)', () {
    group('currying (closures)', () {
      test(
          'given array then should return array with values the pivot is greater than',
          () {
        final result = fx([4, 5, 6]).filter((x) => gt(5, x)).toArray();
        expect(result, equals([4]));
      });

      test('given array then should return empty array', () {
        final result = fx([5, 6, 7]).filter((x) => gt(5, x)).toArray();
        expect(result, equals(<int>[]));
      });

      test('given string array then should return [a, b]', () {
        final result =
            fx(['a', 'b', 'c', 'd', 'e']).filter((x) => gt('c', x)).toArray();
        expect(result, equals(['a', 'b']));
      });

      test('given string array then should return empty array', () {
        final result =
            fx(['a', 'b', 'c', 'd']).filter((x) => gt('a', x)).toArray();
        expect(result, equals(<String>[]));
      });

      test('given date array then should return date array', () {
        final result = fx([DateTime(2022, 5, 10), DateTime(2022, 4, 9)])
            .filter((x) => gt(DateTime(2022, 4, 10), x))
            .toArray();
        expect(result, equals([DateTime(2022, 4, 9)]));
      });

      test('given date array then should return empty array', () {
        final result = fx([DateTime(2021, 5, 10), DateTime(2021, 4, 9)])
            .filter((x) => gt(DateTime(2020, 10, 12), x))
            .toArray();
        expect(result, equals(<DateTime>[]));
      });
    });

    group('eager evaluation', () {
      test('should return true that the first number is greater than second',
          () {
        expect(gt(5, 1), isTrue);
      });
      test(
          'should return false that the first number is not greater than second',
          () {
        expect(gt(1, 5), isFalse);
      });

      test('should return true that the first char is greater than second', () {
        expect(gt('b', 'a'), isTrue);
      });
      test('should return false that the first char is not greater than second',
          () {
        expect(gt('b', 'c'), isFalse);
      });

      test('should return true that the first Date is greater than second', () {
        expect(gt(DateTime.now(), DateTime(2021, 5, 11)), isTrue);
      });
      test('should return false that the first Date is not greater than second',
          () {
        expect(gt(DateTime(2021, 5, 11), DateTime.now()), isFalse);
      });

      test('should throw ArgumentError on mixed types', () {
        expect(() => gt(1, 'a'), throwsArgumentError);
      });
    });
  });
}
