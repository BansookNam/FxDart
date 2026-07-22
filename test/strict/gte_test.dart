import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('gte(greater than or equal to)', () {
    group('currying (closures)', () {
      test('given array then should return values the pivot is gte', () {
        final result = fx([4, 5, 6]).filter((x) => gte(5, x)).toList();
        expect(result, equals([4, 5]));
      });

      test('given array then should return empty array', () {
        final result = fx([5, 6, 7]).filter((x) => gte(4, x)).toList();
        expect(result, equals(<int>[]));
      });

      test('given string array then should return [a, b, c]', () {
        final result =
            fx(['a', 'b', 'c', 'd', 'e']).filter((x) => gte('c', x)).toList();
        expect(result, equals(['a', 'b', 'c']));
      });

      test('given string array then should return empty array', () {
        final result = fx(['b', 'c', 'd']).filter((x) => gte('a', x)).toList();
        expect(result, equals(<String>[]));
      });

      test('given date array then should return date array', () {
        final result = fx([
          DateTime(2022, 5, 10),
          DateTime(2022, 4, 9),
          DateTime(2022, 5, 11),
        ]).filter((x) => gte(DateTime(2022, 5, 10), x)).toList();
        expect(result, equals([DateTime(2022, 5, 10), DateTime(2022, 4, 9)]));
      });

      test('given date array then should return empty array', () {
        final result = fx([DateTime(2021, 5, 10), DateTime(2021, 4, 9)])
            .filter((x) => gte(DateTime(2020, 5, 10), x))
            .toList();
        expect(result, equals(<DateTime>[]));
      });
    });

    group('eager evaluation', () {
      test('should return true that the first number is greater than second',
          () {
        expect(gte(5, 1), isTrue);
      });
      test('should return true that the first number is equal to second', () {
        expect(gte(5, 5), isTrue);
      });
      test(
          'should return false that the first number is not greater than or not equal to second',
          () {
        expect(gte(1, 5), isFalse);
      });

      test('should return true that the first char is greater than second', () {
        expect(gte('b', 'a'), isTrue);
      });
      test('should return true that the first char is equal to second', () {
        expect(gte('b', 'b'), isTrue);
      });
      test(
          'should return false that the first char is not greater than or not equal to second',
          () {
        expect(gte('b', 'c'), isFalse);
      });

      test('should return true that the first Date is greater than second', () {
        expect(gte(DateTime.now(), DateTime(2021, 5, 11)), isTrue);
      });
      test('should return true that the first Date is equal to second', () {
        expect(gte(DateTime(2021, 5, 11), DateTime(2021, 5, 11)), isTrue);
      });
      test('should return false that the first Date is not greater than second',
          () {
        expect(gte(DateTime(2021, 5, 11), DateTime.now()), isFalse);
      });

      test('should throw ArgumentError on mixed types', () {
        expect(() => gte(1, 'a'), throwsArgumentError);
      });
    });
  });
}
