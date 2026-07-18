import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('IterResult', () {
    test('toString should describe a value result', () {
      expect(const IterResult.value(1).toString(), equals('IterResult(1)'));
    });

    test('toString should describe a done result', () {
      expect(const IterResult<int>.done().toString(),
          equals('IterResult.done()'));
    });
  });

  group('fromStream', () {
    test('should convert a single-subscription stream', () async {
      expect(
        await toArrayAsync(fromStream(Stream.fromIterable([1, 2, 3]))),
        equals([1, 2, 3]),
      );
    });

    test('should convert an empty stream', () async {
      expect(await toArrayAsync(fromStream(const Stream<int>.empty())),
          equals([]));
    });

    test('should convert a broadcast stream', () async {
      final controller = StreamController<int>.broadcast();
      final future = toArrayAsync(fromStream(controller.stream));
      // Give the iterator a turn to subscribe before emitting.
      await Future<void>.delayed(Duration.zero);
      controller
        ..add(1)
        ..add(2);
      await controller.close();
      expect(await future, equals([1, 2]));
    });

    test('should propagate a stream error', () {
      expect(
        toArrayAsync(fromStream(Stream<int>.error(StateError('boom')))),
        throwsStateError,
      );
    });

    test('should be able to be used in the pipeline', () async {
      final res = await pipe(Stream.fromIterable([1, 2, 3]), [
        (Stream<int> s) => fromStream(s),
        (FxAsyncIterable<int> a) => filterAsync((n) => n.isOdd, a),
        (FxAsyncIterable<int> a) => toArrayAsync(a),
      ]);
      expect(res, equals([1, 3]));
    });
  });

  group('toStream', () {
    test('should emit every value of the async iterable', () async {
      expect(await toAsync([1, 2, 3]).toStream().toList(), equals([1, 2, 3]));
    });

    test('should emit nothing for an empty async iterable', () async {
      expect(await toAsync(<int>[]).toStream().toList(), equals([]));
    });

    test('should round-trip through fromStream', () async {
      final res = await toArrayAsync(fromStream(toAsync([1, 2, 3]).toStream()));
      expect(res, equals([1, 2, 3]));
    });
  });

  group('concurrentAsync', () {
    test('should throw when length is less than 1', () {
      expect(() => concurrentAsync(0, toAsync([1, 2, 3])),
          throwsA(isA<RangeError>()));
      expect(() => concurrentAsync(-1, toAsync([1, 2, 3])),
          throwsA(isA<RangeError>()));
    });
  });

  group('concurrentPoolAsync', () {
    test('should throw when length is less than 1', () {
      expect(() => concurrentPoolAsync(0, toAsync([1, 2, 3])),
          throwsA(isA<RangeError>()));
      expect(() => concurrentPoolAsync(-1, toAsync([1, 2, 3])),
          throwsA(isA<RangeError>()));
    });
  });
}
