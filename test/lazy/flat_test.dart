import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('flat', () {
    group('sync', () {
      test('should be flattened', () {
        final acc = <dynamic>[];
        for (final a in flat([
          [1, 2],
          3,
          4,
          5,
          [6, 7]
        ])) {
          acc.add(a);
        }
        expect(acc, equals([1, 2, 3, 4, 5, 6, 7]));

        final res = [
          ...flat([
            [1, 2],
            3,
            4,
            5,
            [
              6,
              7,
              [8, 9]
            ]
          ], 2)
        ];
        expect(res, equals([1, 2, 3, 4, 5, 6, 7, 8, 9]));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          1,
          2,
          3,
          [4, 5]
        ], [
          (v) => flat(v),
          (v) => map((a) => (a as int) + 10, v),
          (v) => toArray(v),
        ]);

        expect(res, equals([11, 12, 13, 14, 15]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx([
          1,
          2,
          3,
          [4, 5]
        ]).flat().map((a) => (a as int) + 10).toArray();

        expect(res, equals([11, 12, 13, 14, 15]));
      });
    });

    group('async', () {
      test('should be flattened', () async {
        final acc = <dynamic>[];
        final it = flatAsync(toAsync<dynamic>([
          [1, 2],
          3,
          4,
          5,
          [6, 7]
        ])).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
        expect(acc, equals([1, 2, 3, 4, 5, 6, 7]));

        final res = await toArrayAsync(flatAsync(
            toAsync<dynamic>([
              [1, 2],
              3,
              4,
              5,
              [
                6,
                7,
                [8, 9]
              ]
            ]),
            2));
        expect(res, equals([1, 2, 3, 4, 5, 6, 7, 8, 9]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(flatAsync(toAsync<dynamic>([
          1,
          2,
          3,
          [4, 5]
        ]))).map((a) => (a as int) + 10).toArray();

        expect(res, equals([11, 12, 13, 14, 15]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fxAsync(toAsync<dynamic>([
          1,
          2,
          3,
          [4, 5]
        ])).flat().map((a) => (a as int) + 10).toArray();

        expect(res, equals([11, 12, 13, 14, 15]));
      });

      test('should be flattened concurrently', () async {
        final res = fxAsync(toAsync<List<int>>([
          [1],
          [2],
          [3, 4],
          [5, 6],
          [7, 8, 9, 10],
          [11, 12],
          [13],
          [14],
        ]))
            .map((a) => delay(const Duration(milliseconds: 50), a))
            .flat()
            .concurrent(3);

        final it = res.iterator;
        expect((await it.next()).value, equals(1));
        expect((await it.next()).value, equals(2));
        expect((await it.next()).value, equals(3));
        expect((await it.next()).value, equals(4));
        expect((await it.next()).value, equals(5));
        expect((await it.next()).value, equals(6));
      });

      group('should be flattened concurrently (parametrized)', () {
        final cases = <(List<dynamic>, int, int, List<dynamic>)>[
          (
            [
              [1, 2],
              [3, 4],
              [5, 6],
              [7, 8]
            ],
            1,
            1,
            [1, 2, 3, 4, 5, 6, 7, 8]
          ),
          (
            [
              [1, 2],
              [3, 4],
              [5, 6],
              [7, 8]
            ],
            1,
            3,
            [1, 2, 3, 4, 5, 6, 7, 8]
          ),
          (
            [
              [1, 2],
              [3, 4],
              [5, 6],
              [7, 8]
            ],
            1,
            4,
            [1, 2, 3, 4, 5, 6, 7, 8]
          ),
          (
            [
              [
                1,
                [2]
              ],
              [
                3,
                [4]
              ],
              [
                5,
                [6]
              ],
              [
                7,
                [8]
              ]
            ],
            1,
            4,
            [
              1,
              [2],
              3,
              [4],
              5,
              [6],
              7,
              [8]
            ]
          ),
          (
            [
              [
                1,
                [2]
              ],
              [
                3,
                [4]
              ],
              [
                5,
                [6]
              ],
              [
                7,
                [8]
              ]
            ],
            2,
            4,
            [1, 2, 3, 4, 5, 6, 7, 8]
          ),
          (
            [
              [1],
              [2, 3],
              [4],
              [5, 6],
              [7],
              [8, 9]
            ],
            1,
            2,
            [1, 2, 3, 4, 5, 6, 7, 8, 9]
          ),
          (
            [
              [1],
              [2, 3],
              [4],
              [5, 6],
              [7],
              [8, 9],
              [10]
            ],
            1,
            2,
            [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
          ),
          (
            [
              [1],
              [2, 3, 4],
              [5, 6],
              [7, 8, 9, 10],
              [11, 12]
            ],
            1,
            3,
            [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
          ),
          (
            [
              [1],
              [
                [
                  [2]
                ],
                3,
                4
              ],
              [
                5,
                [
                  [
                    [6]
                  ]
                ]
              ],
              [7, 8, 9, 10],
              [11, 12]
            ],
            2,
            3,
            [
              1,
              [2],
              3,
              4,
              5,
              [
                [6]
              ],
              7,
              8,
              9,
              10,
              11,
              12
            ]
          ),
        ];

        for (var i = 0; i < cases.length; i++) {
          final (input, depth, size, expected) = cases[i];
          test('case #$i (depth=$depth, concurrency=$size)', () async {
            final res = await fxAsync(toAsync<dynamic>(input))
                .map((a) => delay(const Duration(milliseconds: 30), a))
                .flat(depth)
                .concurrent(size)
                .toArray();

            expect(res, equals(expected));
          });
        }
      });

      test('should be flattened concurrently with chunk', () async {
        final res = await fxAsync(toAsync(range(1, 7)))
            .map((a) => delay(const Duration(milliseconds: 50), a))
            .chunk(2)
            .flat()
            .concurrent(3)
            .toArray();

        expect(res, equals([1, 2, 3, 4, 5, 6]));
      });

      test('should be flattened concurrently with filter', () async {
        final res = await fxAsync(flatAsync(
                toAsync<dynamic>([
                  [1],
                  [2],
                  [3],
                  [4]
                ]),
                2))
            .map((a) => delay(const Duration(milliseconds: 50), a))
            .filter((a) => (a as int) % 2 == 0)
            .take(2)
            .concurrent(4)
            .toArray();

        expect(res, equals([2, 4]));
      });

      test('should be able to handle an error', () async {
        Iterable<List<int>> source() sync* {
          yield [1, 2, 3];
          throw Exception('err');
        }

        await expectLater(
          fxAsync(toAsync(source()))
              .map((a) => delay(const Duration(milliseconds: 50), a))
              .flat()
              .concurrent(2)
              .toArray(),
          throwsException,
        );
      });

      test('should be able to handle errors', () async {
        await expectLater(
          fxAsync(toAsync([
            [1, 2, 3],
            [1, 2, 3],
            [1, 2, 3],
            [1, 2, 3],
          ]))
              .map<List<int>>((a) async {
                await delay(const Duration(milliseconds: 50), a);
                throw Exception('err');
              })
              .flat()
              .concurrent(4)
              .toArray(),
          throwsException,
        );
      });
    });
  });
}
