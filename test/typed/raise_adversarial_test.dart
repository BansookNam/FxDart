import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// The adversarial suite: leak detection, scope nesting, signal transparency,
/// and the async failure modes — ported from Arrow's EffectSpec /
/// StructuredConcurrencySpec plus the Dart-specific hazards.
void main() {
  group('leak detection', () {
    test('captured scope raising after the builder returned throws '
        'RaiseLeakedError', () {
      late Raise<String> leaked;
      either<String, int>((r) {
        leaked = r;
        return 1;
      });
      expect(() => leaked.raise('late'), throwsA(isA<RaiseLeakedError>()));
    });

    test('LAZY iterable escaping the builder detonates as RaiseLeakedError '
        'at the consumption site (sync)', () {
      final result = either<String, Iterable<int>>(
          (r) => fx([1, 2, 3]).map((n) => r.raise('lazy')));
      // The builder happily returned Right(<unevaluated pipeline>) …
      expect(result.isRight, isTrue);
      // … and the deferred raise is a loud leak, not silent corruption.
      expect(() => result.getOrNull()!.toList(),
          throwsA(isA<RaiseLeakedError>()));
    });

    test('LAZY async chain escaping the builder detonates as '
        'RaiseLeakedError (async)', () async {
      final result = await eitherAsync<String, FxAsync<int>>(
          (r) async => fxAsync(toAsync([1, 2])).map((n) => r.raise('lazy')));
      expect(result.isRight, isTrue);
      await expectLater(
          result.getOrNull()!.toList(), throwsA(isA<RaiseLeakedError>()));
    });

    test('RaiseLeakedError message is actionable', () {
      expect(RaiseLeakedError().toString(),
          allOf(contains('lazy'), contains('toList'), contains('either')));
    });
  });

  group('scope nesting', () {
    test('inner either does not capture the outer raise', () {
      final outer = either<String, int>((ro) {
        final inner = either<int, String>((ri) => ro.raise('outer'));
        fail('unreachable: $inner');
      });
      expect(outer, Left('outer'));
    });

    test('outer either does not capture the inner raise type confusion', () {
      final outer = either<String, String>((ro) {
        final inner = either<int, String>((ri) => ri.raise(9));
        return 'inner was ${inner.leftOrNull()}';
      });
      expect(outer, Right('inner was 9'));
    });

    test('same-error-type nesting still resolves by scope identity', () {
      final outer = either<String, String>((ro) {
        final inner = either<String, String>((ri) => ri.raise('inner'));
        expect(inner, Left('inner'));
        return ro.bind(inner);
      });
      expect(outer, Left('inner'));
    });
  });

  group('reified scope (Dart improves on Arrow here)', () {
    test('covariant upcast misuse fails at the raise call site with '
        'TypeError, not corruption', () {
      final result = either<String, int>((r) {
        final Raise<Object?> upcast = r;
        expect(() => upcast.raise(42), throwsA(isA<TypeError>()));
        return 7;
      });
      expect(result, Right(7));
    });
  });

  group('signal transparency', () {
    test('`on Exception` does NOT catch the signal (it is an Error)', () {
      final result = either<String, int>((r) {
        try {
          r.raise('boom');
        } on Exception {
          fail('the raise signal must not be an Exception');
        }
        // ignore: dead_code
        return 0;
      });
      expect(result, Left('boom'));
    });

    test('PINNED: a bare catch DOES swallow the signal (documented hazard '
        '— use catching instead)', () {
      final result = either<String, int>((r) {
        try {
          r.raise('swallowed');
        } catch (_) {
          // Deliberately swallowing — this is the documented misuse.
        }
        return 7;
      });
      expect(result, Right(7));
    });

    test('catching rethrows the signal instead of handing it to onError', () {
      final result = either<String, int>(
          (r) => catching(() => r.raise('through'), (e, st) => -1));
      expect(result, Left('through'));
    });

    test('catching rethrows a signal from a nested different-E scope', () {
      final outer = either<String, int>((ro) {
        final inner = either<int, String>(
            (ri) => catching(() => ro.raise('outer'), (e, st) => 'nope'));
        fail('unreachable: $inner');
      });
      expect(outer, Left('outer'));
    });

    test('catchingAsync rethrows the signal', () async {
      final result = await eitherAsync<String, int>(
          (r) => catchingAsync(() async => r.raise('through'), (e, st) => -1));
      expect(result, Left('through'));
    });

    test('Either.catching rethrows the signal', () {
      final result = either<String, int>(
          (r) => r.bind(Either.catching(() => r.raise('through'))
              .mapLeft((e) => e.toString())));
      expect(result, Left('through'));
    });

    test('the signal toString is diagnostic when it does surface', () {
      Object? seen;
      either<String, int>((r) {
        try {
          r.raise('x');
        } catch (e) {
          seen = e;
        }
        return 0;
      });
      expect(seen.toString(), contains('fxdart raise signal'));
      expect(seen.toString(), contains('catching'));
      // The signal carries no eager stack trace of its own (no extra cost
      // beyond Dart's normal throw).
      expect((seen! as Error).stackTrace, equals(null));
    });
  });

  group('async failure modes', () {
    test('PINNED: Future.catchError without a test swallows the signal '
        '(documented hazard)', () async {
      final result = await eitherAsync<String, int>((r) async {
        final recovered = await Future<int>(() => r.raise('swallowed'))
            .catchError((Object e) => -1);
        return recovered;
      });
      expect(result, Right(-1));
    });

    test('PINNED: Future.wait drops the second branch raise silently — the '
        'first error wins', () async {
      final result = await eitherAsync<String, int>((r) async {
        final results = await Future.wait([
          Future<int>(() => r.raise('first')),
          Future<int>.delayed(
              const Duration(milliseconds: 5), () => r.raise('second')),
        ]);
        return results.length;
      });
      expect(result, Left('first'));
    });

    test('raise in an unawaited future while the scope is alive surfaces as '
        'an unhandled zone error with the diagnostic message', () async {
      final errors = <Object>[];
      await runZonedGuarded(() async {
        final result = await eitherAsync<String, int>((r) async {
          unawaited(Future.microtask(() => r.raise('lost')));
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return 1;
        });
        expect(result, Right(1));
      }, (e, st) => errors.add(e))!;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(errors, hasLength(1));
      expect(errors.single.toString(), contains('fxdart raise signal'));
    });

    test('raise in an unawaited future after the scope died surfaces as '
        'RaiseLeakedError', () async {
      final errors = <Object>[];
      await runZonedGuarded(() async {
        final result = await eitherAsync<String, int>((r) async {
          unawaited(Future<void>.delayed(
              const Duration(milliseconds: 5), () => r.raise('too late')));
          return 1;
        });
        expect(result, Right(1));
        await Future<void>.delayed(const Duration(milliseconds: 15));
      }, (e, st) => errors.add(e))!;
      expect(errors, hasLength(1));
      expect(errors.single, isA<RaiseLeakedError>());
    });
  });
}
