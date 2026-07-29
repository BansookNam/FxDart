import 'package:fxdart/fxdart.dart' hide isNull, isEmpty;
import 'package:test/test.dart';

void main() {
  const Either<String, int> right = Right(2);
  const Either<String, int> left = Left('err');

  group('Either', () {
    test('isLeft / isRight', () {
      expect(right.isRight, isTrue);
      expect(right.isLeft, isFalse);
      expect(left.isLeft, isTrue);
      expect(left.isRight, isFalse);
    });

    test('exhaustive switch without default compiles and matches', () {
      String describe(Either<String, int> e) => switch (e) {
            Left(:final value) => 'L:$value',
            Right(:final value) => 'R:$value',
          };
      expect(describe(right), 'R:2');
      expect(describe(left), 'L:err');
    });

    test('fold', () {
      expect(right.fold((l) => 'l', (r) => 'r$r'), 'r2');
      expect(left.fold((l) => 'l:$l', (r) => 'r'), 'l:err');
    });

    test('map transforms only Right', () {
      expect(right.map((v) => v * 10), Right(20));
      expect(left.map((v) => v * 10), Left('err'));
    });

    test('mapLeft transforms only Left', () {
      expect(right.mapLeft((l) => l.length), Right(2));
      expect(left.mapLeft((l) => l.length), Left(3));
    });

    test('flatMap chains and short-circuits', () {
      expect(right.flatMap((v) => Right<String, int>(v + 1)), Right(3));
      expect(right.flatMap((v) => Left<String, int>('mid')), Left('mid'));
      expect(left.flatMap((v) => Right<String, int>(v + 1)), Left('err'));
    });

    test('swap', () {
      expect(right.swap(), Left(2));
      expect(left.swap(), Right('err'));
    });

    test('getOrNull / leftOrNull', () {
      expect(right.getOrNull(), 2);
      expect(right.leftOrNull(), isNull);
      expect(left.getOrNull(), isNull);
      expect(left.leftOrNull(), 'err');
    });

    test('getOrElse', () {
      expect(right.getOrElse((l) => -1), 2);
      expect(left.getOrElse((l) => l.length), 3);
    });

    test('onLeft / onRight run for their side only and return this', () {
      final log = <String>[];
      expect(right.onRight((v) => log.add('r$v')).onLeft((l) => log.add('l')),
          same(right));
      expect(left.onLeft((l) => log.add('l:$l')).onRight((v) => log.add('r')),
          same(left));
      expect(log, ['r2', 'l:err']);
    });

    test('toEitherNel lifts the failure into a singleton Nel', () {
      expect(right.toEitherNel(), Right(2));
      final nel = left.toEitherNel().leftOrNull()!;
      expect(nel.toList(), ['err']);
    });

    test('recover replaces the failure or raises a new error type', () {
      expect(left.recover<int>((r, e) => e.length), Right(3));
      expect(left.recover<int>((r, e) => r.raise(9)), Left(9));
      expect(right.recover<int>((r, e) => -1), Right(2));
    });

    test('Either.catching captures thrown objects', () {
      expect(Either.catching(() => 1), Right(1));
      final caught = Either.catching(() => throw StateError('boom'));
      expect(caught.leftOrNull(), isA<StateError>());
    });

    test('Either.catchingWith maps the thrown object to a typed failure', () {
      expect(Either.catchingWith((e, st) => 'caught: $e', () => 1), Right(1));
      expect(
          Either.catchingWith(
              (e, st) => 'caught', () => throw StateError('boom')),
          Left('caught'));
    });

    test('structural equality, hashCode, toString', () {
      expect(Right<String, int>(1), Right<String, int>(1));
      expect(Left<String, int>('a'), Left<String, int>('a'));
      expect(Right<String, int>(1), isNot(Left<int, int>(1)));
      expect(Right<String, int>(1).hashCode, Right<String, int>(1).hashCode);
      expect(Left<String, int>('a').hashCode, Left<String, int>('a').hashCode);
      expect(Right<String, int>(1).toString(), 'Right(1)');
      expect(Left<String, int>('a').toString(), 'Left(a)');
    });
  });
}
