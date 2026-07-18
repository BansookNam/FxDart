import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('lte(less than or equal to)', () {
    group('currying (closures)', () {
      test('given array then should return values the pivot is lte', () {
        final result = fx([4, 5, 6]).filter((x) => lte(5, x)).toArray();
        expect(result, equals([5, 6]));
      });

      test('given array then should return empty array', () {
        final result = fx([6, 7]).filter((x) => lte(8, x)).toArray();
        expect(result, equals(<int>[]));
      });

      test('given string array then should return [d, e]', () {
        final result =
            fx(['a', 'b', 'c', 'd', 'e']).filter((x) => lte('d', x)).toArray();
        expect(result, equals(['d', 'e']));
      });

      test('given string array then should return empty array', () {
        final result = fx(['b', 'c', 'd']).filter((x) => lte('e', x)).toArray();
        expect(result, equals(<String>[]));
      });

      test('given date array then should return date array', () {
        final result = fx([
          DateTime(2022, 3, 10),
          DateTime(2022, 4, 9),
          DateTime(2022, 4, 10),
        ]).filter((x) => lte(DateTime(2022, 4, 8), x)).toArray();
        expect(result, equals([DateTime(2022, 4, 9), DateTime(2022, 4, 10)]));
      });

      test('given date array then should return empty array', () {
        final result = fx([DateTime(2021, 5, 10), DateTime(2021, 4, 9)])
            .filter((x) => lte(DateTime.now(), x))
            .toArray();
        expect(result, equals(<DateTime>[]));
      });
    });

    group('eager evaluation', () {
      test('should return true that the first number is less than second', () {
        expect(lte(1, 5), isTrue);
      });
      test('should return true that the first number is equal to second', () {
        expect(lte(5, 5), isTrue);
      });
      test(
          'should return false that the first number is not less than or not equal to second',
          () {
        expect(lte(5, 1), isFalse);
      });

      test('should return true that the first char is less than second', () {
        expect(lte('a', 'b'), isTrue);
      });
      test('should return true that the first char is equal to second', () {
        expect(lte('b', 'b'), isTrue);
      });
      test(
          'should return false that the first char is not less than or not equal to second',
          () {
        expect(lte('c', 'b'), isFalse);
      });

      test('should return true that the first Date is less than second', () {
        expect(lte(DateTime(2021, 5, 11), DateTime.now()), isTrue);
      });
      test('should return true that the first Date is equal to second', () {
        expect(lte(DateTime(2021, 5, 11), DateTime(2021, 5, 11)), isTrue);
      });
      test('should return false that the first Date is not less than second',
          () {
        expect(lte(DateTime.now(), DateTime(2021, 5, 11)), isFalse);
      });

      test('should throw ArgumentError on mixed types', () {
        expect(() => lte(1, 'a'), throwsArgumentError);
      });
    });
  });
}
