import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('split', () {
    group('sync', () {
      test('should return an empty array', () {
        final iter = fxSplit('', ''.split(''));
        expect([...iter], equals([]));
      });

      test('should be splited by empty string', () {
        final iter = fxSplit('', 'abcdefg'.split(''));
        expect([...iter], equals(['a', 'b', 'c', 'd', 'e', 'f', 'g']));
      });

      test('should be splited by separator', () {
        final iter = fxSplit(',', 'a,b,c,d,e,f,g'.split(''));
        expect([...iter], equals(['a', 'b', 'c', 'd', 'e', 'f', 'g']));
      });

      test(
        'should be appended empty string if there is a separator at the end',
        () {
          final iter = fxSplit(',', 'a,b,c,d,e,f,g,'.split(''));
          expect([...iter], equals(['a', 'b', 'c', 'd', 'e', 'f', 'g', '']));
        },
      );

      test('should be splited by separator(unicode)', () {
        final iter = fxSplit(',', unicodeToList('👍,😀,🙇‍♂️,🤩,🎉'));
        expect([...iter], equals(['👍', '😀', '🙇‍♂️', '🤩', '🎉']));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe('1,2,3,4,5,6,7,8,9,10'.split(''), [
          (v) => fxSplit(',', v),
          (v) => fxMap((String a) => int.parse(a), v),
          (v) => fxFilter((int a) => a % 2 == 0, v),
          (v) => fxToList(v),
        ]);

        expect(res, equals([2, 4, 6, 8, 10]));
      });
    });

    group('async', () {
      test('should return an empty array', () async {
        final res = await fxToListAsync(
          fxSplitAsync('', fxToAsync(''.split(''))),
        );
        expect(res, equals([]));
      });

      test('should be splited by empty string', () async {
        final res = await fxToListAsync(
          fxSplitAsync('', fxToAsync('abcdefg'.split(''))),
        );
        expect(res, equals(['a', 'b', 'c', 'd', 'e', 'f', 'g']));
      });

      test('should be splited by separator', () async {
        final acc = <String>[];
        final it = fxSplitAsync(
          ',',
          fxToAsync('a,b,c,d,e,f,g'.split('')),
        ).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
        expect(acc, equals(['a', 'b', 'c', 'd', 'e', 'f', 'g']));
      });

      test(
        'should be appended empty string if there is a separator at the end',
        () async {
          final res = await fxToListAsync(
            fxSplitAsync(',', fxToAsync('a,b,c,d,e,f,g,'.split(''))),
          );
          expect(res, equals(['a', 'b', 'c', 'd', 'e', 'f', 'g', '']));
        },
      );

      test('should be splited by separator(unicode)', () async {
        final res = await fxToListAsync(
          fxSplitAsync(',', fxToAsync(unicodeToList('👍,😀,🙇‍♂️,🤩,🎉'))),
        );
        expect(res, equals(['👍', '😀', '🙇‍♂️', '🤩', '🎉']));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(
          fxSplitAsync(',', fxToAsync('1,2,3,4,5,6,7,8,9,10'.split(''))),
        ).map((a) => int.parse(a)).filter((a) => a % 2 == 0).toList();

        expect(res, equals([2, 4, 6, 8, 10]));
      });

      test('should be controlled the order when concurrency', () async {
        Iterable<Future<String>> source() sync* {
          yield fxDelay(const Duration(milliseconds: 100), '1');
          yield fxDelay(const Duration(milliseconds: 80), ',');
          yield fxDelay(const Duration(milliseconds: 60), '2');
          yield fxDelay(const Duration(milliseconds: 40), ',');
          yield fxDelay(const Duration(milliseconds: 20), '3');
          yield fxDelay(const Duration(milliseconds: 100), ',');
          yield fxDelay(const Duration(milliseconds: 80), '4');
          yield fxDelay(const Duration(milliseconds: 60), ',');
          yield fxDelay(const Duration(milliseconds: 20), '5');
        }

        final res = await fxAsync(
          fxSplitAsync(',', fxToAsync(source())),
        ).concurrent(5).toList();

        expect(res, equals(['1', '2', '3', '4', '5']));
      });

      test('should be consumed concurrently', () async {
        final sw = Stopwatch()..start();
        final res =
            await fxAsync(
                  fxSplitAsync(
                    ',',
                    fxToAsync('1,2,3,4,5,6,7,8,9,10'.split('')),
                  ),
                )
                .map((a) => fxDelay(const Duration(milliseconds: 100), a))
                .map((a) => int.parse(a))
                .filter((a) => a % 2 == 0)
                .concurrent(5)
                .toList();
        sw.stop();

        expect(res, equals([2, 4, 6, 8, 10]));
        // Sequential would be ~1000ms; concurrent(5) should be ~200ms.
        expect(sw.elapsedMilliseconds, lessThan(700));
      });
    });
  });
}
