import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('fork', () {
    group('sync', () {
      test('should be forked iterable (number)', () {
        final arr = [1, 2, 3];

        final iter1 = fork(arr).iterator;
        final iter2 = fork(arr).iterator;

        expect(iter1.moveNext(), isTrue);
        expect(iter1.current, equals(1));
        expect(iter1.moveNext(), isTrue);
        expect(iter1.current, equals(2));
        expect(iter1.moveNext(), isTrue);
        expect(iter1.current, equals(3));
        expect(iter1.moveNext(), isFalse);

        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(1));
        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(2));
        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(3));
        expect(iter2.moveNext(), isFalse);
      });

      test('should be forked iterable (string chars)', () {
        final arr = 'abc'.split('');

        expect(toList(fork(arr)), equals(['a', 'b', 'c']));
        expect(toList(fork(arr)), equals(['a', 'b', 'c']));
      });

      test('should walk a shared lazy source only once', () {
        var evaluations = 0;
        final arr = map((int a) {
          evaluations++;
          return a + 10;
        }, [1, 2, 3]);

        final iter1 = fork(arr);
        final iter2 = fork(arr);
        final iter3 = map((int a) => '$a', fork(arr));

        expect(toList(iter1), equals([11, 12, 13]));
        expect(toList(iter2), equals([11, 12, 13]));
        expect(toList(iter3), equals(['11', '12', '13']));
        expect(evaluations, equals(3));
      });

      test('forked iterator proceeds independently of other forks', () {
        final arr = map((int a) => a + 10, [1, 2, 3]);

        final iter1 = fork(arr).iterator;
        final iter2 = fork(arr).iterator;

        expect(iter1.moveNext(), isTrue);
        expect(iter1.current, equals(11));
        expect(iter1.moveNext(), isTrue);
        expect(iter1.current, equals(12));

        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(11));

        expect(iter1.moveNext(), isTrue);
        expect(iter1.current, equals(13));
        expect(iter1.moveNext(), isFalse);

        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(12));
        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(13));
        expect(iter2.moveNext(), isFalse);
      });

      test(
          'a fork created in the middle of iterable progress still sees the full sequence',
          () {
        // Dart forks share one buffered iteration per iterable object and
        // always replay from the beginning of that buffer (unlike JS, where
        // fork(iterator) continues from the iterator's current position).
        final arr = map((int a) => a + 10, [1, 2, 3]);

        final iter1 = fork(arr).iterator;
        expect(iter1.moveNext(), isTrue);
        expect(iter1.current, equals(11));

        final iter2 = fork(arr).iterator;
        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(11));
        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(12));

        expect(iter1.moveNext(), isTrue);
        expect(iter1.current, equals(12));
      });

      test('original iterator advances alongside forks (JS iterator identity)',
          () {},
          skip: 'JS-specific: Dart iterables restart per iterator; the '
              'original cannot be consumed as a shared cursor');
    });

    group('async', () {
      test('should be forked iterable (number)', () async {
        final arr = toAsync([1, 2, 3]);

        final iter1 = forkAsync(arr).iterator;
        final iter2 = forkAsync(arr).iterator;

        expect((await iter1.next()).value, equals(1));
        expect((await iter1.next()).value, equals(2));
        expect((await iter1.next()).value, equals(3));
        expect((await iter1.next()).done, isTrue);

        expect((await iter2.next()).value, equals(1));
        expect((await iter2.next()).value, equals(2));
        expect((await iter2.next()).value, equals(3));
        expect((await iter2.next()).done, isTrue);
      });

      test('should be forked iterable (string chars)', () async {
        final arr = toAsync('abc'.split(''));

        expect(await toListAsync(forkAsync(arr)), equals(['a', 'b', 'c']));
        expect(await toListAsync(forkAsync(arr)), equals(['a', 'b', 'c']));
      });

      test('should walk a shared lazy source only once', () async {
        var evaluations = 0;
        final arr = mapAsync((int a) {
          evaluations++;
          return a + 10;
        }, toAsync([1, 2, 3]));

        expect(await toListAsync(forkAsync(arr)), equals([11, 12, 13]));
        expect(await toListAsync(forkAsync(arr)), equals([11, 12, 13]));
        expect(evaluations, equals(3));
      });

      test('forked iterator proceeds independently of other forks', () async {
        final arr = mapAsync((int a) => a + 10, toAsync([1, 2, 3]));

        final iter1 = forkAsync(arr).iterator;
        final iter2 = forkAsync(arr).iterator;

        expect((await iter1.next()).value, equals(11));
        expect((await iter1.next()).value, equals(12));

        expect((await iter2.next()).value, equals(11));

        expect((await iter1.next()).value, equals(13));
        expect((await iter1.next()).done, isTrue);

        expect((await iter2.next()).value, equals(12));
        expect((await iter2.next()).value, equals(13));
        expect((await iter2.next()).done, isTrue);
      });

      test('forked iterables should each be fully consumable with concurrent',
          () async {
        final iter = mapAsync(
            (int a) => delay(const Duration(milliseconds: 50), a),
            toAsync(range(10)));

        final forked1 = forkAsync(iter);
        final forked2 = forkAsync(iter);

        final arr1 = await toListAsync(concurrentAsync(5, forked1));
        expect(arr1, equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));

        // The second fork replays the shared buffer without re-evaluating.
        final sw = Stopwatch()..start();
        final arr2 = await toListAsync(concurrentAsync(5, forked2));
        expect(arr2, equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
        expect(sw.elapsedMilliseconds, lessThan(200));
      });

      test('forked iterable should be consumed concurrently', () async {
        final iter = mapAsync(
            (int a) => delay(const Duration(milliseconds: 100), a),
            toAsync(range(10)));

        final forked = forkAsync(iter);
        final sw = Stopwatch()..start();
        final arr = await toListAsync(concurrentAsync(5, forked));
        expect(arr, equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
        // sequential is ~1000ms; concurrent(5) should be ~200ms
        expect(sw.elapsedMilliseconds, lessThan(700));
      });
    });

    group('error propagation', () {
      test('should propagate errors from sync iterator to all forked iterators',
          () {
        final errorIterable = () sync* {
          yield 1;
          yield 2;
          throw StateError('sync error');
        }();

        final iter1 = fork(errorIterable).iterator;
        final iter2 = fork(errorIterable).iterator;

        expect(iter1.moveNext(), isTrue);
        expect(iter1.current, equals(1));
        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(1));

        expect(iter1.moveNext(), isTrue);
        expect(iter1.current, equals(2));

        expect(() => iter1.moveNext(), throwsStateError);
        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(2));
        expect(() => iter2.moveNext(), throwsStateError);
      });

      test(
          'should propagate errors from async iterator to all forked iterators',
          () async {
        final errorIterable = toAsync(() sync* {
          yield Future.value(1);
          yield Future.value(2);
          yield Future<int>.error(StateError('async error'));
        }());

        final iter1 = forkAsync(errorIterable).iterator;
        final iter2 = forkAsync(errorIterable).iterator;

        expect((await iter1.next()).value, equals(1));
        expect((await iter2.next()).value, equals(1));

        expect((await iter1.next()).value, equals(2));

        await expectLater(iter1.next(), throwsStateError);
        expect((await iter2.next()).value, equals(2));
        await expectLater(iter2.next(), throwsStateError);
      });
    });

    group('memory optimization', () {
      test('should handle large datasets with multiple forks (sync)', () {
        final arr = map((int a) => a + 1, range(500));

        final fork1 = fork(arr).iterator;
        final fork2 = fork(arr).iterator;
        final fork3 = fork(arr).iterator;

        final results1 = <int>[];
        for (var i = 0; i < 100; i++) {
          fork1.moveNext();
          results1.add(fork1.current);
        }

        final results2 = <int>[];
        for (var i = 0; i < 50; i++) {
          fork2.moveNext();
          results2.add(fork2.current);
        }

        final results3 = <int>[];
        while (fork3.moveNext()) {
          results3.add(fork3.current);
        }

        expect(results1[0], equals(1));
        expect(results1[99], equals(100));
        expect(results2[0], equals(1));
        expect(results2[49], equals(50));
        expect(results3.length, equals(500));
        expect(results3[0], equals(1));
        expect(results3[499], equals(500));
      });

      test('should handle large datasets with multiple forks (async)',
          () async {
        final arr = mapAsync((int a) => a + 1, toAsync(range(200)));

        final fork1 = forkAsync(arr).iterator;
        final fork2 = forkAsync(arr).iterator;

        final results1 = <int>[];
        for (var i = 0; i < 50; i++) {
          results1.add((await fork1.next()).value);
        }

        final results2 = <int>[];
        var result = await fork2.next();
        while (!result.done) {
          results2.add(result.value);
          result = await fork2.next();
        }

        var result1 = await fork1.next();
        while (!result1.done) {
          results1.add(result1.value);
          result1 = await fork1.next();
        }

        expect(results1.length, equals(200));
        expect(results1[0], equals(1));
        expect(results1[199], equals(200));
        expect(results2.length, equals(200));
        expect(results2[0], equals(1));
        expect(results2[199], equals(200));
      });

      test('should remove fork from tracking when completed (sync)', () {
        final arr = [1, 2, 3];
        final iter1 = fork(arr).iterator;
        final iter2 = fork(arr).iterator;

        while (iter1.moveNext()) {}

        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(1));
        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(2));
        expect(iter2.moveNext(), isTrue);
        expect(iter2.current, equals(3));
        expect(iter2.moveNext(), isFalse);
      });

      test('should remove fork from tracking when completed (async)', () async {
        final arr = toAsync([1, 2, 3]);
        final iter1 = forkAsync(arr).iterator;
        final iter2 = forkAsync(arr).iterator;

        while (!(await iter1.next()).done) {}

        expect((await iter2.next()).value, equals(1));
        expect((await iter2.next()).value, equals(2));
        expect((await iter2.next()).value, equals(3));
        expect((await iter2.next()).done, isTrue);
      });
    });
  });
}
