import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('flatMap', () {
    group('sync', () {
      test('should be flat-mapped', () {
        final acc = <String>[];
        for (final a
            in flatMap((s) => s.split(' '), ['It is', 'a good', 'day'])) {
          acc.add(a);
        }
        expect(acc, equals(['It', 'is', 'a', 'good', 'day']));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          'It is',
          'a good',
          'day'
        ], [
          (v) => flatMap((String s) => s.split(' '), v),
          (v) => map((String a) => a.toUpperCase(), v),
          (v) => toList(v),
        ]);

        expect(res, equals(['IT', 'IS', 'A', 'GOOD', 'DAY']));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx(['It is', 'a good', 'day'])
            .flatMap((s) => s.split(' '))
            .map((a) => a.toUpperCase())
            .toList();

        expect(res, equals(['IT', 'IS', 'A', 'GOOD', 'DAY']));
      });
    });

    group('async', () {
      test('should be flat-mapped', () async {
        final acc = <String>[];
        final it = flatMapAsync(
            (s) => s.split(' '), toAsync(['It is', 'a good', 'day'])).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
        expect(acc, equals(['It', 'is', 'a', 'good', 'day']));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(toAsync(['It is', 'a good', 'day']))
            .flatMap((s) => s.split(' '))
            .map((a) => a.toUpperCase())
            .toList();

        expect(res, equals(['IT', 'IS', 'A', 'GOOD', 'DAY']));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fxAsync(toAsync(['It is', 'a good', 'day']))
            .flatMap((s) => Future.value(s.split(' ')))
            .map((a) => a.toUpperCase())
            .toList();

        expect(res, equals(['IT', 'IS', 'A', 'GOOD', 'DAY']));
      });
    });
  });
}
