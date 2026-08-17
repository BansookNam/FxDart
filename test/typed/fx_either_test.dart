import 'package:fxdart/fxdart.dart' hide isNull, isEmpty;
import 'package:test/test.dart';

void main() {
  final mixed = <Either<String, int>>[Right(1), Left('a'), Right(2), Left('b')];

  group('rights / lefts / separateEither', () {
    group('sync', () {
      test('top-level functions', () {
        expect(rights(mixed), [1, 2]);
        expect(lefts(mixed), ['a', 'b']);
        final (ls, rs) = separateEither(mixed);
        expect(ls, ['a', 'b']);
        expect(rs, [1, 2]);
      });

      test('chain terminals', () {
        expect(fx(mixed).rights(), [1, 2]);
        expect(fx(mixed).lefts(), ['a', 'b']);
        final (ls, rs) = fx(mixed).separated();
        expect(ls, ['a', 'b']);
        expect(rs, [1, 2]);
      });

      test('empty input', () {
        expect(rights(<Either<String, int>>[]), isEmpty);
        expect(lefts(<Either<String, int>>[]), isEmpty);
        final (ls, rs) = separateEither(<Either<String, int>>[]);
        expect(ls, isEmpty);
        expect(rs, isEmpty);
      });
    });
  });

  group('sequenceEither', () {
    group('sync', () {
      test('collects all Rights', () {
        expect(
          sequenceEither(<Either<String, int>>[
            Right(1),
            Right(2),
            Right(3),
          ]).getOrNull(),
          [1, 2, 3],
        );
        expect(
          fx(<Either<String, int>>[Right(1), Right(2)]).sequence().getOrNull(),
          [1, 2],
        );
      });

      test('fails fast on the first Left', () {
        expect(sequenceEither(mixed), Left('a'));
      });
    });

    group('async', () {
      test('collects all Rights', () async {
        final result = await fxAsync(
          toAsync(<Either<String, int>>[Right(1), Right(2)]),
        ).sequence();
        expect(result.getOrNull(), [1, 2]);
      });

      test('fails fast AND stops pulling upstream', () async {
        var evaluated = 0;
        final result = await fxAsync(toAsync([1, 2, 3, 4])).map((n) {
          evaluated++;
          return n == 2 ? Left<String, int>('boom') : Right<String, int>(n);
        }).sequence();
        expect(result, Left('boom'));
        expect(evaluated, 2);
      });

      test('top-level twin works on any FxAsyncIterable', () async {
        final result = await sequenceEitherAsync(
          toAsync(<Either<String, int>>[Right(7)]),
        );
        expect(result.getOrNull(), [7]);
      });
    });
  });

  group('mapOrAccumulate (pipeline)', () {
    group('sync', () {
      test('top-level: collects every failure', () {
        final result = mapOrAccumulate<String, int, int>(
          (r, n) => n.isEven ? n * 10 : r.raise('odd $n'),
          [1, 2, 3],
        );
        expect(result.leftOrNull()!.toList(), ['odd 1', 'odd 3']);
      });

      test('chain: returns all results when nothing fails', () {
        expect(
          fx([1, 2]).mapOrAccumulate<String, int>((r, n) => n * 10).getOrNull(),
          [10, 20],
        );
      });

      test('chain: a branch can contribute multiple errors', () {
        final result = fx([1, 2]).mapOrAccumulate<String, int>(
          (r, n) =>
              n.isOdd ? r.bindNel(Left(NonEmptyList.of('a$n', ['b$n']))) : n,
        );
        expect(result.leftOrNull()!.toList(), ['a1', 'b1']);
      });
    });

    group('async', () {
      test('collects every failure in element order', () async {
        final result = await fxAsync(toAsync([1, 2, 3]))
            .mapOrAccumulate<String, int>(
              (r, n) async => n.isEven ? n * 10 : r.raise('odd $n'),
            );
        expect(result.leftOrNull()!.toList(), ['odd 1', 'odd 3']);
      });

      test('returns all results when nothing fails', () async {
        final result = await fxAsync(
          toAsync([1, 2]),
        ).mapOrAccumulate<String, int>((r, n) async => n * 10);
        expect(result.getOrNull(), [10, 20]);
      });

      test('with concurrency: order is preserved even when later elements '
          'finish first', () async {
        final result = await fxAsync(toAsync([1, 2, 3, 4]))
            .mapOrAccumulate<String, int>((r, n) async {
              // Later elements complete sooner — order must still hold.
              await Future<void>.delayed(Duration(milliseconds: (5 - n) * 5));
              if (n.isOdd) r.raise('odd $n');
              return n * 10;
            }, concurrency: 4);
        expect(result.leftOrNull()!.toList(), ['odd 1', 'odd 3']);
      });

      test('with concurrency: a raise in one element cannot leak into a '
          'sibling element', () async {
        final result = await fxAsync(toAsync([1, 2]))
            .mapOrAccumulate<String, int>((r, n) async {
              await Future<void>.delayed(const Duration(milliseconds: 5));
              if (n == 1) r.raise('one');
              return n;
            }, concurrency: 2);
        expect(result.leftOrNull()!.toList(), ['one']);
      });

      test('top-level twin with concurrency parameter', () async {
        final result = await mapOrAccumulateAsync<String, int, int>(
          (r, n) async => n * 2,
          toAsync([1, 2, 3]),
          concurrency: 2,
        );
        expect(result.getOrNull(), [2, 4, 6]);
      });
    });
  });
}
