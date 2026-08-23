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
        expect(sequenceEqual([1, 2, 3], [1, 2, 3]), isTrue);
        expect(sequenceEqual(gen([1, 2]), gen([1, 2])), isTrue);
      });

      test('true for two empties', () {
        expect(sequenceEqual(<int>[], <int>[]), isTrue);
      });

      test('false on the first value mismatch', () {
        expect(sequenceEqual([1, 2, 3], [1, 9, 3]), isFalse);
      });

      test('false when lengths differ', () {
        expect(sequenceEqual([1, 2, 3], [1, 2]), isFalse);
        expect(sequenceEqual([1, 2], [1, 2, 3]), isFalse);
        expect(sequenceEqual([1], <int>[]), isFalse);
        expect(sequenceEqual(<int>[], [1]), isFalse);
      });

      test('uses eq when provided', () {
        expect(
          sequenceEqual([1, -2], [1, 2], (a, b) => a.abs() == b.abs()),
          isTrue,
        );
        expect(
          sequenceEqual([1, -2], [1, 3], (a, b) => a.abs() == b.abs()),
          isFalse,
        );
      });
    });

    group('async', () {
      test('true when both hold the same values in order', () async {
        expect(
          await sequenceEqualAsync(toAsync([1, 2, 3]), toAsync([1, 2, 3])),
          isTrue,
        );
      });

      test('true for two empties', () async {
        expect(
          await sequenceEqualAsync(toAsync(<int>[]), toAsync(<int>[])),
          isTrue,
        );
      });

      test('false on the first value mismatch', () async {
        expect(
          await sequenceEqualAsync(toAsync([1, 2, 3]), toAsync([1, 9, 3])),
          isFalse,
        );
      });

      test('false when lengths differ', () async {
        expect(
          await sequenceEqualAsync(toAsync([1, 2, 3]), toAsync([1, 2])),
          isFalse,
        );
        expect(
          await sequenceEqualAsync(toAsync([1, 2]), toAsync([1, 2, 3])),
          isFalse,
        );
      });

      test('uses eq when provided', () async {
        expect(
          await sequenceEqualAsync(
            toAsync([1, -2]),
            toAsync([1, 2]),
            (a, b) => a.abs() == b.abs(),
          ),
          isTrue,
        );
        expect(
          await sequenceEqualAsync(
            toAsync([1, -2]),
            toAsync([1, 3]),
            (a, b) => a.abs() == b.abs(),
          ),
          isFalse,
        );
      });

      test('Fx.sequenceEqual and FxAsync.sequenceEqual', () async {
        expect(fx([1, 2, 3]).sequenceEqual([1, 2, 3]), isTrue);
        expect(fx([1, 2, 3]).sequenceEqual([1, 2]), isFalse);
        expect(
          await fx([1, 2, 3]).toAsync().sequenceEqual(toAsync([1, 2, 3])),
          isTrue,
        );
        expect(
          await fx([1, 2]).toAsync().sequenceEqual(toAsync([1, 2, 3])),
          isFalse,
        );
      });

      test('an error from either side fails the future', () async {
        expect(
          sequenceEqualAsync(
            fromStream(Stream<int>.error(StateError('boom'))),
            toAsync([1]),
          ),
          throwsStateError,
        );
        expect(
          sequenceEqualAsync(
            toAsync([1]),
            fromStream(Stream<int>.error(StateError('boom'))),
          ),
          throwsStateError,
        );
      });
    });
  });
}
