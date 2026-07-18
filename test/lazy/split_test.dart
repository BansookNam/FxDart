import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('split', () {
    group('sync', () {
      test('should return an empty array', () {
        final iter = split('', ''.split(''));
        expect([...iter], equals([]));
      });

      test('should be splited by empty string', () {
        final iter = split('', 'abcdefg'.split(''));
        expect([...iter], equals(['a', 'b', 'c', 'd', 'e', 'f', 'g']));
      });

      test('should be splited by separator', () {
        final iter = split(',', 'a,b,c,d,e,f,g'.split(''));
        expect([...iter], equals(['a', 'b', 'c', 'd', 'e', 'f', 'g']));
      });

      test('should be appended empty string if there is a separator at the end',
          () {
        final iter = split(',', 'a,b,c,d,e,f,g,'.split(''));
        expect([...iter], equals(['a', 'b', 'c', 'd', 'e', 'f', 'g', '']));
      });

      test('should be splited by separator(unicode)', () {
        final iter = split(',', unicodeToArray('👍,😀,🙇‍♂️,🤩,🎉'));
        expect([...iter], equals(['👍', '😀', '🙇‍♂️', '🤩', '🎉']));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe('1,2,3,4,5,6,7,8,9,10'.split(''), [
          (v) => split(',', v),
          (v) => map((String a) => int.parse(a), v),
          (v) => filter((int a) => a % 2 == 0, v),
          (v) => toArray(v),
        ]);

        expect(res, equals([2, 4, 6, 8, 10]));
      });
    });

    group('async', () {
      test('should return an empty array', () async {
        final res = await toArrayAsync(splitAsync('', toAsync(''.split(''))));
        expect(res, equals([]));
      });

      test('should be splited by empty string', () async {
        final res =
            await toArrayAsync(splitAsync('', toAsync('abcdefg'.split(''))));
        expect(res, equals(['a', 'b', 'c', 'd', 'e', 'f', 'g']));
      });

      test('should be splited by separator', () async {
        final acc = <String>[];
        final it = splitAsync(',', toAsync('a,b,c,d,e,f,g'.split(''))).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
        expect(acc, equals(['a', 'b', 'c', 'd', 'e', 'f', 'g']));
      });

      test('should be appended empty string if there is a separator at the end',
          () async {
        final res = await toArrayAsync(
            splitAsync(',', toAsync('a,b,c,d,e,f,g,'.split(''))));
        expect(res, equals(['a', 'b', 'c', 'd', 'e', 'f', 'g', '']));
      });

      test('should be splited by separator(unicode)', () async {
        final res = await toArrayAsync(
            splitAsync(',', toAsync(unicodeToArray('👍,😀,🙇‍♂️,🤩,🎉'))));
        expect(res, equals(['👍', '😀', '🙇‍♂️', '🤩', '🎉']));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(
                splitAsync(',', toAsync('1,2,3,4,5,6,7,8,9,10'.split(''))))
            .map((a) => int.parse(a))
            .filter((a) => a % 2 == 0)
            .toArray();

        expect(res, equals([2, 4, 6, 8, 10]));
      });

      test('should be controlled the order when concurrency', () async {
        Iterable<Future<String>> source() sync* {
          yield delay(const Duration(milliseconds: 100), '1');
          yield delay(const Duration(milliseconds: 80), ',');
          yield delay(const Duration(milliseconds: 60), '2');
          yield delay(const Duration(milliseconds: 40), ',');
          yield delay(const Duration(milliseconds: 20), '3');
          yield delay(const Duration(milliseconds: 100), ',');
          yield delay(const Duration(milliseconds: 80), '4');
          yield delay(const Duration(milliseconds: 60), ',');
          yield delay(const Duration(milliseconds: 20), '5');
        }

        final res = await fxAsync(splitAsync(',', toAsync(source())))
            .concurrent(5)
            .toArray();

        expect(res, equals(['1', '2', '3', '4', '5']));
      });

      test('should be consumed concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(
                splitAsync(',', toAsync('1,2,3,4,5,6,7,8,9,10'.split(''))))
            .map((a) => delay(const Duration(milliseconds: 100), a))
            .map((a) => int.parse(a))
            .filter((a) => a % 2 == 0)
            .concurrent(5)
            .toArray();
        sw.stop();

        expect(res, equals([2, 4, 6, 8, 10]));
        // Sequential would be ~1000ms; concurrent(5) should be ~200ms.
        expect(sw.elapsedMilliseconds, lessThan(700));
      });
    });
  });
}
