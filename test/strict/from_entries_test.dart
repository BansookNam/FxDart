import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('fromEntries', () {
    group('sync', () {
      test(
          'should return proper map when iterable keyed-value pairs is given as an argument',
          () {
        final arr = <(String, Object)>[
          ('a', 1),
          ('b', true),
          ('c', 'hello'),
          ('d', {'d1': 1, 'd2': 3}),
        ];
        final res = fromEntries(arr);
        expect(
            res,
            equals({
              'a': 1,
              'b': true,
              'c': 'hello',
              'd': {'d1': 1, 'd2': 3},
            }));
      });

      test(
          'should round-trip a Map with heterogeneous keys through entries/fromEntries',
          () {
        final source = <Object, Object>{
          'a': 1,
          'b': 'hello',
          10: 1000,
          20: 2000,
          'obj': {'a1': 10, 'b1': 'hello object'},
        };
        final res = fromEntries(entries(source));
        expect(res, equals(source));
      });
    });

    group('async', () {
      test(
          'should return proper map when asyncIterable keyed-value pairs is given as an argument',
          () async {
        final arr = <(String, Object)>[
          ('a', 1),
          ('b', true),
          ('c', 'hello'),
          ('d', {'d1': 1, 'd2': 3}),
        ];
        final res = fromEntries(await toListAsync(toAsync(arr)));
        expect(
            res,
            equals({
              'a': 1,
              'b': true,
              'c': 'hello',
              'd': {'d1': 1, 'd2': 3},
            }));
      });
    });
  });
}
