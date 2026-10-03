import 'package:fxdart/fxdart.dart' hide fxIsNull, fxIsEmpty;
import 'package:test/test.dart';

void main() {
  group('either', () {
    group('sync', () {
      test('should return Right on normal completion', () {
        expect(fxEither<String, int>((r) => 42), Right(42));
      });

      test('should return Left on raise', () {
        expect(fxEither<String, int>((r) => r.raise('boom')), Left('boom'));
      });

      test('should rethrow thrown exceptions (raise != throw)', () {
        expect(
          () => fxEither<String, int>((r) => throw StateError('x')),
          throwsStateError,
        );
      });
    });

    group('async', () {
      test('should return Right on normal completion', () async {
        expect(await fxEitherAsync<String, int>((r) async => 42), Right(42));
      });

      test('should return Left on raise before the first await', () async {
        expect(
          await fxEitherAsync<String, int>((r) => r.raise('early')),
          Left('early'),
        );
      });

      test('should return Left on raise between awaits', () async {
        final result = await fxEitherAsync<String, int>((r) async {
          await Future<void>.delayed(Duration.zero);
          r.raise('mid');
        });
        expect(result, Left('mid'));
      });

      test('should return Left on raise after the last await', () async {
        final result = await fxEitherAsync<String, int>((r) async {
          await Future<void>.delayed(Duration.zero);
          await Future<void>.delayed(Duration.zero);
          return r.raise('late');
        });
        expect(result, Left('late'));
      });

      test('should rethrow thrown exceptions', () {
        expect(
          fxEitherAsync<String, int>((r) async => throw StateError('x')),
          throwsStateError,
        );
      });
    });
  });

  group('nullable', () {
    group('sync', () {
      test('should return the value on completion', () {
        expect(fxNullable((r) => r.bind(int.tryParse('42')) + 1), 43);
      });

      test('should return null on none()', () {
        expect(fxNullable<int>((r) => r.none()), isNull);
      });

      test('should return null when bind sees null', () {
        expect(fxNullable((r) => r.bind(int.tryParse('nope'))), isNull);
      });

      test('should support ensure / ensureNotNull / raise', () {
        expect(
          fxNullable((r) {
            r.ensure(true);
            return r.ensureNotNull(int.tryParse('7'));
          }),
          7,
        );
        expect(
          fxNullable<int>((r) {
            r.ensure(false);
            return 1;
          }),
          isNull,
        );
        expect(fxNullable<int>((r) => r.raise()), isNull);
      });
    });

    group('async', () {
      test('should return the value on completion', () async {
        expect(await fxNullableAsync((r) async => 5), 5);
      });

      test('should return null on none()', () async {
        expect(await fxNullableAsync<int>((r) async => r.none()), isNull);
      });
    });
  });

  group('foldRaise', () {
    test('should dispatch onValue / onRaise', () {
      expect(
        fxFoldRaise<String, int, String>(
          (r) => 1,
          onRaise: (e) => 'raise:$e',
          onValue: (v) => 'value:$v',
        ),
        'value:1',
      );
      expect(
        fxFoldRaise<String, int, String>(
          (r) => r.raise('e'),
          onRaise: (e) => 'raise:$e',
          onValue: (v) => 'value:$v',
        ),
        'raise:e',
      );
    });

    test('should hand thrown exceptions to onThrow when given', () {
      expect(
        fxFoldRaise<String, int, String>(
          (r) => throw StateError('boom'),
          onRaise: (e) => 'raise',
          onValue: (v) => 'value',
          onThrow: (e, st) => 'thrown:$e',
        ),
        startsWith('thrown:Bad state'),
      );
    });

    test('should rethrow thrown exceptions without onThrow', () {
      expect(
        () => fxFoldRaise<String, int, int>(
          (r) => throw StateError('boom'),
          onRaise: (e) => 0,
          onValue: (v) => v,
        ),
        throwsStateError,
      );
    });
  });

  group('foldRaiseAsync', () {
    test('should dispatch onValue / onRaise / onThrow', () async {
      expect(
        await fxFoldRaiseAsync<String, int, String>(
          (r) async => 1,
          onRaise: (e) => 'raise:$e',
          onValue: (v) => 'value:$v',
        ),
        'value:1',
      );
      expect(
        await fxFoldRaiseAsync<String, int, String>(
          (r) async => r.raise('e'),
          onRaise: (e) => 'raise:$e',
          onValue: (v) => 'value:$v',
        ),
        'raise:e',
      );
      expect(
        await fxFoldRaiseAsync<String, int, String>(
          (r) async => throw StateError('boom'),
          onRaise: (e) => 'raise',
          onValue: (v) => 'value',
          onThrow: (e, st) async => 'thrown',
        ),
        'thrown',
      );
    });

    test('should rethrow thrown exceptions without onThrow', () {
      expect(
        fxFoldRaiseAsync<String, int, int>(
          (r) async => throw StateError('boom'),
          onRaise: (e) => 0,
          onValue: (v) => v,
        ),
        throwsStateError,
      );
    });
  });

  group('RaiseOps', () {
    test('bind should unwrap Right and raise Left', () {
      expect(fxEither<String, int>((r) => r.bind(Right(1)) + 1), Right(2));
      expect(fxEither<String, int>((r) => r.bind(Left('no'))), Left('no'));
    });

    test('bindAll should unwrap all or raise the first Left', () {
      expect(
        fxEither<String, List<int>>(
          (r) => r.bindAll([Right(1), Right(2), Right(3)]),
        ).getOrNull(),
        [1, 2, 3],
      );
      expect(
        fxEither<String, List<int>>(
          (r) => r.bindAll([Right(1), Left('a'), Left('b')]),
        ),
        Left('a'),
      );
    });

    test('ensure should pass or raise', () {
      expect(
        fxEither<String, int>((r) {
          r.ensure(true, () => 'never');
          return 1;
        }),
        Right(1),
      );
      expect(
        fxEither<String, int>((r) {
          r.ensure(false, () => 'failed');
          return 1;
        }),
        Left('failed'),
      );
    });

    test('ensureNotNull should promote or raise', () {
      expect(
        fxEither<String, int>(
          (r) => r.ensureNotNull(int.tryParse('9'), () => 'nan') * 2,
        ),
        Right(18),
      );
      expect(
        fxEither<String, int>(
          (r) => r.ensureNotNull(int.tryParse('x'), () => 'nan'),
        ),
        Left('nan'),
      );
    });

    test('recover should handle a raised error in a nested scope', () {
      expect(
        fxEither<String, int>(
          (r) => r.recover((r2) => r2.raise('gone'), (e) => e.length),
        ),
        Right(4),
      );
    });

    test('recover should let thrown exceptions propagate', () {
      expect(
        () => fxEither<String, int>(
          (r) => r.recover((r2) => throw StateError('x'), (e) => 0),
        ),
        throwsStateError,
      );
    });

    test('recover should pass through a successful block untouched', () {
      expect(
        fxEither<String, int>((r) => r.recover((r2) => 5, (e) => -1)),
        Right(5),
      );
    });

    test('recover should hand thrown exceptions to onThrow when given', () {
      expect(
        fxEither<String, int>(
          (r) => r.recover(
            (r2) => throw StateError('x'),
            (e) => 0,
            onThrow: (thrown, _) => 99,
          ),
        ),
        Right(99),
      );
    });

    test('recover should route a raise to onRaise, never to onThrow', () {
      var onThrowRan = false;
      expect(
        fxEither<String, int>(
          (r) => r.recover(
            (r2) => r2.raise('gone'),
            (e) => e.length,
            onThrow: (thrown, _) {
              onThrowRan = true;
              return -1;
            },
          ),
        ),
        Right(4),
      );
      expect(onThrowRan, isFalse);
    });

    test("recover should rethrow the enclosing scope's raise, not hand it "
        'to onThrow', () {
      var onThrowRan = false;
      expect(
        fxEither<String, int>(
          (r) => r.recover(
            (_) => r.raise('outer'),
            (e) => -1,
            onThrow: (thrown, _) {
              onThrowRan = true;
              return -2;
            },
          ),
        ),
        Left('outer'),
      );
      expect(onThrowRan, isFalse);
    });

    test('withError should map the inner error type into the outer', () {
      expect(
        fxEither<String, int>(
          (r) => r.withError<int, int>(
            (code) => 'code $code',
            (r2) => r2.raise(404),
          ),
        ),
        Left('code 404'),
      );
      expect(
        fxEither<String, int>(
          (r) => r.withError<int, int>((code) => 'code $code', (r2) => 7),
        ),
        Right(7),
      );
    });
  });

  group('catching', () {
    test('should pass through the value', () {
      expect(fxCatching(() => 1, (e, st) => -1), 1);
    });

    test('should hand thrown exceptions to onError', () {
      expect(fxCatching<int>(() => throw StateError('x'), (e, st) => -1), -1);
    });

    test('async twin should behave the same', () async {
      expect(await fxCatchingAsync(() async => 1, (e, st) => -1), 1);
      expect(
        await fxCatchingAsync<int>(
          () async => throw StateError('x'),
          (e, st) async => -1,
        ),
        -1,
      );
    });
  });
}
