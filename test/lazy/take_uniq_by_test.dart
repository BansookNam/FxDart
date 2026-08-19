// `takeUniqBy` is `filter(...).uniqBy(...).take(n)` collapsed into one strict
// call. It exists for one reason: a lazy stage keeps its callback in an
// iterator field, which the AOT compiler cannot see through, so the closure
// never inlines. Here the callback is a parameter of a function small enough
// to inline into the caller.
//
// The behaviour therefore has to match the lazy spelling exactly, which is
// what most of this file checks — including the two things easy to get wrong
// when a filter and a key function are merged: a null key skips the element
// rather than counting as a key, and the walk stops the moment the count is
// met.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

class Log {
  const Log(this.time, this.level, this.message);
  final String time;
  final String level;
  final String message;
}

const logs = [
  Log('09:41', 'ERROR', 'gateway timeout'),
  Log('09:40', 'INFO', 'checkout started'),
  Log('09:38', 'ERROR', 'gateway timeout'),
  Log('09:35', 'WARN', 'retrying'),
  Log('09:31', 'ERROR', 'service 503'),
  Log('09:17', 'ERROR', 'invalid session'),
  Log('09:12', 'ERROR', 'disk quota'),
];

String? errorMessage(Log l) => l.level == 'ERROR' ? l.message : null;

void main() {
  group('takeUniqBy', () {
    test('takes the first count elements with distinct keys', () {
      expect(takeUniqBy(3, errorMessage, logs).map((l) => l.time).toList(), [
        '09:41',
        '09:31',
        '09:17',
      ]);
    });

    test('agrees with the lazy spelling of the same pipeline', () {
      final lazy = fx(logs)
          .filter((l) => l.level == 'ERROR')
          .uniqBy((l) => l.message)
          .take(3)
          .toList();

      expect(takeUniqBy(3, errorMessage, logs), lazy);
    });

    test('a null key skips the element rather than keying on null', () {
      // Two INFO/WARN lines sit between the errors; if null were a key they
      // would take a slot and the third error would not be reached.
      final res = takeUniqBy(3, errorMessage, logs);

      expect(res.every((l) => l.level == 'ERROR'), isTrue);
      expect(res.length, 3);
    });

    test('stops calling the key once the count is met', () {
      final seen = <String>[];
      takeUniqBy(2, (Log l) {
        seen.add(l.time);
        return l.level == 'ERROR' ? l.message : null;
      }, logs);

      expect(seen, ['09:41', '09:40', '09:38', '09:35', '09:31']);
    });

    test('returns everything it found when the count is never met', () {
      // Five ERROR lines, but two share a message: four distinct keys.
      expect(takeUniqBy(99, errorMessage, logs).length, 4);
    });

    test('a non-positive count yields nothing and never calls the key', () {
      var calls = 0;
      String? key(Log l) {
        calls++;
        return l.message;
      }

      expect(takeUniqBy(0, key, logs), <Log>[]);
      expect(takeUniqBy(-3, key, logs), <Log>[]);
      expect(calls, 0);
    });

    test('an empty source yields nothing', () {
      expect(takeUniqBy(3, errorMessage, const <Log>[]), <Log>[]);
    });

    test('a source that is not a List is pulled instead of indexed', () {
      Iterable<Log> gen() sync* {
        yield* logs;
      }

      expect(
        takeUniqBy(3, errorMessage, gen()),
        takeUniqBy(3, errorMessage, logs),
      );
    });

    test('a non-List source honours a non-positive count', () {
      Iterable<Log> gen() sync* {
        yield* logs;
      }

      expect(takeUniqBy(0, errorMessage, gen()), <Log>[]);
    });

    test('the result is a fresh growable list', () {
      final res = takeUniqBy(2, errorMessage, logs);
      expect(() => res.add(logs.first), returnsNormally);
    });

    test('every key null yields nothing', () {
      expect(takeUniqBy(3, (Log l) => null, logs), <Log>[]);
    });

    test('keys need not be strings', () {
      expect(
        takeUniqBy(
          2,
          (Log l) => l.level == 'ERROR' ? l.message.length : null,
          logs,
        ).map((l) => l.time).toList(),
        ['09:41', '09:31'],
      );
    });
  });

  group('Fx.takeUniqBy', () {
    test('is the same operator', () {
      expect(
        fx(logs).takeUniqBy(3, errorMessage),
        takeUniqBy(3, errorMessage, logs),
      );
    });

    test('composes after a lazy stage', () {
      // The source is then not a List, so the pulled path runs.
      expect(
        fx(logs)
            .filter((l) => l.time.startsWith('09:1'))
            .takeUniqBy(2, (l) => l.message)
            .map((l) => l.time)
            .toList(),
        ['09:17', '09:12'],
      );
    });
  });
}
