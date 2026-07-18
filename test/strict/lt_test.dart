import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('lt(less than)', () {
    group('currying (closures)', () {
      test('given array then should return values the pivot is less than', () {
        final result = fx([4, 5, 6]).filter((x) => lt(5, x)).toArray();
        expect(result, equals([6]));
      });

      test('given array then should return empty array', () {
        final result = fx([5, 6, 7]).filter((x) => lt(7, x)).toArray();
        expect(result, equals(<int>[]));
      });

      test('given string array then should return [e]', () {
        final result =
            fx(['a', 'b', 'c', 'd', 'e']).filter((x) => lt('d', x)).toArray();
        expect(result, equals(['e']));
      });

      test('given string array then should return empty array', () {
        final result =
            fx(['a', 'b', 'c', 'd']).filter((x) => lt('d', x)).toArray();
        expect(result, equals(<String>[]));
      });

      test('given date array then should return date array', () {
        final result = fx([DateTime(2022, 5, 10), DateTime(2022, 4, 9)])
            .filter((x) => lt(DateTime(2022, 4, 10), x))
            .toArray();
        expect(result, equals([DateTime(2022, 5, 10)]));
      });

      test('given date array then should return empty array', () {
        final result = fx([DateTime(2021, 5, 10), DateTime(2021, 4, 9)])
            .filter((x) => lt(DateTime.now(), x))
            .toArray();
        expect(result, equals(<DateTime>[]));
      });
    });

    group('eager evaluation', () {
      test('should return true that the first number is less than second', () {
        expect(lt(1, 5), isTrue);
      });
      test('should return false that the first number is not less than second',
          () {
        expect(lt(5, 1), isFalse);
      });

      test('should return true that the first char is less than second', () {
        expect(lt('a', 'b'), isTrue);
      });
      test('should return false that the first char is not less than second',
          () {
        expect(lt('c', 'b'), isFalse);
      });

      test('should return true that the first Date is less than second', () {
        expect(lt(DateTime(2021, 5, 11), DateTime.now()), isTrue);
      });
      test('should return false that the first Date is not less than second',
          () {
        expect(lt(DateTime.now(), DateTime(2021, 5, 11)), isFalse);
      });

      test('should throw ArgumentError on mixed types', () {
        expect(() => lt(1, 'a'), throwsArgumentError);
      });
    });
  });
}
