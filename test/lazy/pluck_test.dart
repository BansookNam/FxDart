import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('pluck', () {
    final given = [
      {'id': 1, 'age': 21},
      {'id': 2, 'age': 22},
      {'id': 3, 'age': 23},
      {'id': 4, 'age': 24},
    ];

    group('sync', () {
      test(
          'should return Iterable by plucking the same named property off all objects in the Iterable supplied',
          () {
        final acc = <int?>[];
        for (final a in pluck('age', given)) {
          acc.add(a);
        }
        expect(acc, equals([21, 22, 23, 24]));
      });

      test('should be able to be used in the pipeline', () {
        final res = toList(filter((int? a) => a! > 21, pluck('age', given)));
        expect(res, equals([22, 23, 24]));
      });
    });

    group('async', () {
      test(
          'should return Iterable by plucking the same named property off all objects in the Iterable supplied',
          () async {
        final acc = await toListAsync(pluckAsync('age', toAsync(given)));
        expect(acc, equals([21, 22, 23, 24]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await toListAsync(filterAsync(
            (int? a) => a! > 21, pluckAsync('age', toAsync(given))));
        expect(res, equals([22, 23, 24]));
      });
    });
  });
}
