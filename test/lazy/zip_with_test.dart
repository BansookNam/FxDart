import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('zipWith', () {
    final iter1 = ['foo', 'bar', 'ha'];
    final iter2 = [1, 2, 3];
    final then = [
      {'foo': 1},
      {'bar': 2},
      {'ha': 3}
    ];

    group('sync', () {
      test('should apply `f` to each same positioned pair', () {
        final acc = <Map<String, int>>[];
        for (final a in zipWith((String a, int b) => {a: b}, iter1, iter2)) {
          acc.add(a);
        }
        expect(acc, equals(then));
      });
    });

    group('async', () {
      test(
          'should apply `f` to each same positioned pair [AsyncIterable/Iterable]',
          () async {
        final res = await toListAsync(zipWithAsync(
            (String a, int b) => {a: b}, toAsync(iter1), toAsync(iter2)));
        expect(res, equals(then));
      });

      test(
          'should apply `f` to each same positioned pair [AsyncIterable/AsyncIterable] with async callback',
          () async {
        final res = await toListAsync(zipWithAsync(
            (String a, int b) async => {a: b}, toAsync(iter1), toAsync(iter2)));
        expect(res, equals(then));
      });
    });
  });
}
