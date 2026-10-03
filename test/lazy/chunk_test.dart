import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

const expected = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9],
  [10, 11],
];

void main() {
  group('chunk', () {
    group('sync', () {
      test('should be chunked by the given number - number', () {
        final res = fxToList(fxChunk(3, fxRange(1, 12)));
        expect(fxToList(fxChunk(0, fxRange(1, 12))), equals([]));
        expect(res, equals(expected));
      });

      test('should be chunked by the given number - string', () {
        final res = fxToList(
          fxChunk(3, 'abcdefghijklmnopqrstuvwxyz'.split('')),
        );
        expect(
          res,
          equals([
            ['a', 'b', 'c'],
            ['d', 'e', 'f'],
            ['g', 'h', 'i'],
            ['j', 'k', 'l'],
            ['m', 'n', 'o'],
            ['p', 'q', 'r'],
            ['s', 't', 'u'],
            ['v', 'w', 'x'],
            ['y', 'z'],
          ]),
        );
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe(fxRange(1, 12), [
          (v) => fxChunk(3, v),
          (v) => fxToList(v),
        ]);
        expect(res, equals(expected));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        expect(
          fx([1, 2, 3, 4]).chunk(2).toList(),
          equals([
            [1, 2],
            [3, 4],
          ]),
        );
        expect(
          fx([1, 2, 3, 4, 5]).chunk(2).toList(),
          equals([
            [1, 2],
            [3, 4],
            [5],
          ]),
        );
      });
    });

    group('async', () {
      test('should be chunked by the given number - number (empty)', () async {
        final res = await fxToListAsync(
          fxChunkAsync(0, fxToAsync(fxRange(1, 12))),
        );
        expect(res, equals([]));
      });

      test('should be chunked by the given number - number', () async {
        final res = await fxToListAsync(
          fxChunkAsync(3, fxToAsync(fxRange(1, 12))),
        );
        expect(res, equals(expected));
      });

      test('should be chunked after concurrent', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(fxToAsync(fxRange(1, 12)))
            .map((a) => fxDelay(const Duration(milliseconds: 100), a))
            .concurrent(2)
            .chunk(3)
            .toList();
        sw.stop();

        expect(res, equals(expected));
        // Sequential would be ~1100ms; concurrent(2) should be ~600ms.
        expect(sw.elapsedMilliseconds, lessThan(950));
      });

      test('should be chunked after concurrent with filter', () async {
        final res = await fxAsync(fxToAsync(fxRange(1, 21)))
            .map((a) => fxDelay(const Duration(milliseconds: 50), a))
            .filter((a) => a % 2 == 0)
            .concurrent(2)
            .chunk(3)
            .toList();
        expect(
          res,
          equals([
            [2, 4, 6],
            [8, 10, 12],
            [14, 16, 18],
            [20],
          ]),
        );
      });

      test('should be chunked before concurrent', () async {
        final res = await fxAsync(fxToAsync(fxRange(1, 21)))
            .map((a) => fxDelay(const Duration(milliseconds: 50), a))
            .filter((a) => a % 2 == 0)
            .chunk(3)
            .concurrent(2)
            .toList();
        expect(
          res,
          equals([
            [2, 4, 6],
            [8, 10, 12],
            [14, 16, 18],
            [20],
          ]),
        );
      });

      test(
        'should be able to handle an error when the callback is asynchronous',
        () async {
          await expectLater(
            fxAsync(fxToAsync(fxRange(1, 21)))
                .map((a) => fxDelay(const Duration(milliseconds: 50), a))
                .filter((a) {
                  if (a % 2 == 0) return Future<bool>.error(Exception('err'));
                  return true;
                })
                .chunk(3)
                .concurrent(2)
                .toList(),
            throwsException,
          );
        },
      );

      test(
        'should be able to handle an error when working concurrent',
        () async {
          await expectLater(
            fxAsync(fxToAsync(fxRange(1, 21)))
                .map((a) => fxDelay(const Duration(milliseconds: 50), a))
                .filter((a) => a % 2 == 0)
                .chunk(3)
                .map<List<int>>((a) => throw Exception('err'))
                .concurrent(2)
                .toList(),
            throwsException,
          );
        },
      );

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(fxToAsync(fxRange(1, 12))).chunk(3).toList();
        expect(res, equals(expected));
      });

      test(
        'should be able to be used as a chaining method in the `fx`',
        () async {
          expect(
            await fx([1, 2, 3, 4]).toAsync().chunk(2).toList(),
            equals([
              [1, 2],
              [3, 4],
            ]),
          );
          expect(
            await fx([1, 2, 3, 4, 5]).toAsync().chunk(2).toList(),
            equals([
              [1, 2],
              [3, 4],
              [5],
            ]),
          );
        },
      );
    });
  });
}
