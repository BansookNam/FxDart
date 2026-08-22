import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// mapCatching is the element-wise partner catching never had — the pair
// retry/mapRetryAsync already established.
//
// The load-bearing test in this file is the raise one: the library's own
// raise signal must be RETHROWN, not handed to onError. If it were
// recovered, using mapCatching inside an either {} / nullable {} block would
// silently turn a typed error into a recovered value.
int _explodeOnTwo(int a) => a == 2 ? throw StateError('boom: $a') : a * 10;

int _recover(Object error, StackTrace stackTrace) => -1;

void main() {
  group('mapCatching', () {
    test('yields the handler result in place of a thrown error', () {
      expect(mapCatching(_explodeOnTwo, _recover, [1, 2, 3]).toList(), [
        10,
        -1,
        30,
      ]);
    });

    test('does not end the iteration at the first failure', () {
      expect(mapCatching(_explodeOnTwo, _recover, [2, 2, 2]).toList(), [
        -1,
        -1,
        -1,
      ]);
    });

    test('hands the error and its stack trace to the handler', () {
      Object? seenError;
      StackTrace? seenTrace;
      mapCatching(_explodeOnTwo, (error, stackTrace) {
        seenError = error;
        seenTrace = stackTrace;
        return 0;
      }, [2]).toList();
      expect(seenError, isA<StateError>());
      expect(seenTrace, isA<StackTrace>());
    });

    test('is lazy — nothing runs before iteration', () {
      var calls = 0;
      final mapped = mapCatching(
        (int a) {
          calls++;
          return a;
        },
        _recover,
        [1, 2, 3],
      );
      expect(calls, 0);
      expect(mapped.take(2).toList(), [1, 2]);
      expect(calls, 2);
    });

    test('an empty source yields nothing', () {
      expect(mapCatching(_explodeOnTwo, _recover, <int>[]).toList(), <int>[]);
    });

    test('rethrows a raise signal instead of recovering it', () {
      final result = either<String, List<int>>(
        (r) => mapCatching(
          (int a) => a == 2 ? r.raise('raised') : a,
          _recover,
          [1, 2, 3],
        ).toList(),
      );
      expect(result, Left('raised'));
    });

    test('a raise from a foreign scope is not recovered either', () {
      final outer = either<String, int>((ro) {
        final inner = either<int, List<int>>(
          (ri) => mapCatching(
            (int a) => a == 2 ? ro.raise('outer') : a,
            _recover,
            [1, 2, 3],
          ).toList(),
        );
        fail('unreachable: $inner');
      });
      expect(outer, Left('outer'));
    });

    test(
      'Fx.mapCatching agrees with the top-level function and stays sync',
      () {
        final Fx<int> chained = fx([
          1,
          2,
          3,
        ]).mapCatching(_explodeOnTwo, _recover);
        expect(
          chained.toList(),
          mapCatching(_explodeOnTwo, _recover, [1, 2, 3]).toList(),
        );
      },
    );
  });

  group('mapCatchingAsync', () {
    test('agrees with the sync spelling', () async {
      expect(
        await toListAsync(
          mapCatchingAsync(_explodeOnTwo, _recover, toAsync([1, 2, 3])),
        ),
        mapCatching(_explodeOnTwo, _recover, [1, 2, 3]).toList(),
      );
    });

    test('recovers a failure from an async callback', () async {
      expect(
        await toListAsync(
          mapCatchingAsync(
            (int a) async => a == 2 ? throw StateError('boom') : a * 10,
            (error, stackTrace) async => -1,
            toAsync([1, 2, 3]),
          ),
        ),
        [10, -1, 30],
      );
    });

    test('rethrows a raise signal instead of recovering it', () async {
      final result = await eitherAsync<String, List<int>>(
        (r) => toListAsync(
          mapCatchingAsync(
            (int a) async => a == 2 ? r.raise('raised') : a,
            _recover,
            toAsync([1, 2, 3]),
          ),
        ),
      );
      expect(result, Left('raised'));
    });

    test('FxAsync.mapCatching agrees with the top-level function', () async {
      expect(
        await fxAsync(
          toAsync([1, 2, 3]),
        ).mapCatching(_explodeOnTwo, _recover).toList(),
        [10, -1, 30],
      );
    });
  });
}
