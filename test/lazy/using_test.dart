import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// A fake resource recording its lifecycle.
class Resource {
  bool opened = false;
  bool closed = false;
  int closeCalls = 0;

  void open() => opened = true;

  void close() {
    closed = true;
    closeCalls++;
  }
}

void main() {
  group('using', () {
    group('sync', () {
      test('should acquire lazily and release after completion', () {
        final resource = Resource();
        final iterable = using(() {
          resource.open();
          return resource;
        }, (r) => [1, 2, 3], (r) => r.close());

        expect(resource.opened, isFalse);
        expect(toList(iterable), equals([1, 2, 3]));
        expect(resource.opened, isTrue);
        expect(resource.closed, isTrue);
      });

      test('should release when iteration throws', () {
        final resource = Resource();
        expect(
            () => toList(using(
                () => resource,
                (r) => map<int, int>((a) => a == 2 ? throw Exception('err') : a,
                    [1, 2, 3]),
                (r) => r.close())),
            throwsException);
        expect(resource.closed, isTrue);
      });

      test('should not release when abandoned mid-iteration (documented)', () {
        final resource = Resource();
        final iterable =
            using(() => resource, (r) => [1, 2, 3], (r) => r.close());
        for (final a in iterable) {
          if (a == 2) break;
        }
        // Sync generators cannot observe abandonment — this is the caveat
        // called out in the doc comment.
        expect(resource.closed, isFalse);
      });

      test('should release once per full iteration', () {
        final resource = Resource();
        final iterable =
            using(() => resource, (r) => [1, 2], (r) => r.close());
        toList(iterable);
        toList(iterable);
        expect(resource.closeCalls, equals(2));
      });
    });

    group('async', () {
      test('should acquire lazily and release after completion', () async {
        final resource = Resource();
        final iterable = usingAsync(() async {
          resource.open();
          return resource;
        }, (r) => toAsync([1, 2, 3]), (r) async => r.close());

        expect(resource.opened, isFalse);
        expect(await toListAsync(iterable), equals([1, 2, 3]));
        expect(resource.opened, isTrue);
        expect(resource.closed, isTrue);
        expect(resource.closeCalls, equals(1));
      });

      test('should release before an iteration error propagates', () async {
        final resource = Resource();
        final order = <String>[];
        await expectLater(
          toListAsync(usingAsync(
              () => resource,
              (r) => mapAsync((int a) {
                    if (a == 2) throw Exception('err');
                    return a;
                  }, toAsync([1, 2, 3])),
              (r) {
                order.add('release');
                r.close();
              })).catchError((Object e) {
            order.add('error');
            throw e;
          }),
          throwsException,
        );
        expect(resource.closed, isTrue);
        expect(order, equals(['release', 'error']));
      });

      test('should propagate an acquire failure without releasing', () async {
        var released = false;
        await expectLater(
          toListAsync(usingAsync<Resource, int>(
              () => throw Exception('cannot open'),
              (r) => toAsync([1]),
              (r) => released = true)),
          throwsException,
        );
        expect(released, isFalse);
      });

      test('should release only once even with pulls past the end', () async {
        final resource = Resource();
        final iterable = usingAsync(
            () => resource, (r) => toAsync([1]), (r) => r.close());
        final iterator = iterable.iterator;
        expect((await iterator.next()).value, equals(1));
        expect((await iterator.next()).done, isTrue);
        expect((await iterator.next()).done, isTrue);
        expect(resource.closeCalls, equals(1));
      });

      test('should compose with concurrent', () async {
        final resource = Resource();
        final res = await fxAsync(usingAsync(
                () => resource,
                (r) => mapAsync(
                    (int a) => delay(const Duration(milliseconds: 50), a),
                    toAsync(range(1, 7))),
                (r) => r.close()))
            .concurrent(3)
            .toList();
        expect(res, equals([1, 2, 3, 4, 5, 6]));
        expect(resource.closeCalls, equals(1));
      });
    });
  });
}
