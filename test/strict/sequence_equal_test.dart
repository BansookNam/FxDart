import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

Iterable<int> gen(Iterable<int> values) sync* {
  yield* values;
}

void main() {
  group('sequenceEqual', () {
    group('sync', () {
      test('true when both hold the same values in order', () {
        expect(fxSequenceEqual([1, 2, 3], [1, 2, 3]), isTrue);
        expect(fxSequenceEqual(gen([1, 2]), gen([1, 2])), isTrue);
      });

      test('true for two empties', () {
        expect(fxSequenceEqual(<int>[], <int>[]), isTrue);
      });

      test('false on the first value mismatch', () {
        expect(fxSequenceEqual([1, 2, 3], [1, 9, 3]), isFalse);
      });

      test('false when lengths differ', () {
        expect(fxSequenceEqual([1, 2, 3], [1, 2]), isFalse);
        expect(fxSequenceEqual([1, 2], [1, 2, 3]), isFalse);
        expect(fxSequenceEqual([1], <int>[]), isFalse);
        expect(fxSequenceEqual(<int>[], [1]), isFalse);
      });

      test('uses eq when provided', () {
        expect(
          fxSequenceEqual([1, -2], [1, 2], (a, b) => a.abs() == b.abs()),
          isTrue,
        );
        expect(
          fxSequenceEqual([1, -2], [1, 3], (a, b) => a.abs() == b.abs()),
          isFalse,
        );
      });
    });

    group('async', () {
      test('true when both hold the same values in order', () async {
        expect(
          await fxSequenceEqualAsync(
            fxToAsync([1, 2, 3]),
            fxToAsync([1, 2, 3]),
          ),
          isTrue,
        );
      });

      test('true for two empties', () async {
        expect(
          await fxSequenceEqualAsync(fxToAsync(<int>[]), fxToAsync(<int>[])),
          isTrue,
        );
      });

      test('false on the first value mismatch', () async {
        expect(
          await fxSequenceEqualAsync(
            fxToAsync([1, 2, 3]),
            fxToAsync([1, 9, 3]),
          ),
          isFalse,
        );
      });

      test('false when lengths differ', () async {
        expect(
          await fxSequenceEqualAsync(fxToAsync([1, 2, 3]), fxToAsync([1, 2])),
          isFalse,
        );
        expect(
          await fxSequenceEqualAsync(fxToAsync([1, 2]), fxToAsync([1, 2, 3])),
          isFalse,
        );
      });

      test('uses eq when provided', () async {
        expect(
          await fxSequenceEqualAsync(
            fxToAsync([1, -2]),
            fxToAsync([1, 2]),
            (a, b) => a.abs() == b.abs(),
          ),
          isTrue,
        );
        expect(
          await fxSequenceEqualAsync(
            fxToAsync([1, -2]),
            fxToAsync([1, 3]),
            (a, b) => a.abs() == b.abs(),
          ),
          isFalse,
        );
      });

      test('Fx.sequenceEqual and FxAsync.sequenceEqual', () async {
        expect(fx([1, 2, 3]).sequenceEqual([1, 2, 3]), isTrue);
        expect(fx([1, 2, 3]).sequenceEqual([1, 2]), isFalse);
        expect(
          await fx([1, 2, 3]).toAsync().sequenceEqual(fxToAsync([1, 2, 3])),
          isTrue,
        );
        expect(
          await fx([1, 2]).toAsync().sequenceEqual(fxToAsync([1, 2, 3])),
          isFalse,
        );
      });

      test('an error from either side fails the future', () async {
        expect(
          fxSequenceEqualAsync(
            fxFromStream(Stream<int>.error(StateError('boom'))),
            fxToAsync([1]),
          ),
          throwsStateError,
        );
        expect(
          fxSequenceEqualAsync(
            fxToAsync([1]),
            fxFromStream(Stream<int>.error(StateError('boom'))),
          ),
          throwsStateError,
        );
      });
    });
  });
}
