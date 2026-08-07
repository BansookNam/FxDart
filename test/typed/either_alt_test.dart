import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('Either.alt', () {
    test('keeps a Right and never calls the alternative', () {
      var calls = 0;
      final res = Right<String, int>(1).alt(() {
        calls++;
        return Right(2);
      });
      expect(res, equals(Right<String, int>(1)));
      expect(calls, equals(0));
    });

    test('falls back to the alternative on a Left', () {
      expect(Left<String, int>('boom').alt(() => Right(2)),
          equals(Right<String, int>(2)));
    });

    test('a failing alternative keeps its own failure', () {
      expect(Left<String, int>('first').alt(() => Left('second')),
          equals(Left<String, int>('second')));
    });

    test('chains as a fallback ladder, stopping at the first hit', () {
      final tried = <String>[];
      Either<String, int> source(String name, int? value) {
        tried.add(name);
        return value == null ? Left('$name miss') : Right(value);
      }

      final res = source('cache', null)
          .alt(() => source('disk', 7))
          .alt(() => source('network', 9));

      expect(res, equals(Right<String, int>(7)));
      expect(tried, equals(['cache', 'disk']));
    });
  });

  group('Either.orElse', () {
    test('keeps a Right and never calls the handler', () {
      var calls = 0;
      final res = Right<String, int>(1).orElse<int>((e) {
        calls++;
        return Right(2);
      });
      expect(res, equals(Right<int, int>(1)));
      expect(calls, equals(0));
    });

    test('hands the failure to the handler', () {
      final res =
          Left<String, int>('boom').orElse<String>((e) => Left('wrapped: $e'));
      expect(res, equals(Left<String, int>('wrapped: boom')));
    });

    test('can recover into a Right', () {
      expect(Left<String, int>('boom').orElse<String>((e) => Right(0)),
          equals(Right<String, int>(0)));
    });

    test('can change the failure type', () {
      final res = Left<String, int>('boom').orElse<int>((e) => Left(e.length));
      expect(res, equals(Left<int, int>(4)));
    });
  });

  group('alt / orElse / recover', () {
    Either<String, int> parse(String s) {
      final n = int.tryParse(s);
      return n == null ? Left('not a number: $s') : Right(n);
    }

    test('all three express the same fallback, at different reaches', () {
      expect(parse('x').alt(() => parse('0')), equals(Right<String, int>(0)));
      expect(parse('x').orElse<String>((_) => parse('0')),
          equals(Right<String, int>(0)));
      expect(parse('x').recover<String>((r, e) => 0),
          equals(Right<String, int>(0)));
    });

    test('recover can raise a new failure where orElse must build one', () {
      final viaRecover =
          parse('x').recover<int>((r, e) => r.raise(e.length));
      final viaOrElse = parse('x').orElse<int>((e) => Left(e.length));
      expect(viaRecover, equals(viaOrElse));
    });
  });
}
