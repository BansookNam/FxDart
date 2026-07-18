import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

typedef Obj = ({String category, String desc});

const given = <Obj>[
  (category: 'clothes', desc: 'good'),
  (category: 'pants', desc: 'bad'),
  (category: 'shoes', desc: 'not bad'),
  (category: 'shoes', desc: 'great'),
  (category: 'pants', desc: 'good'),
];

const then1 = {
  'clothes': [(category: 'clothes', desc: 'good')],
  'pants': [
    (category: 'pants', desc: 'bad'),
    (category: 'pants', desc: 'good'),
  ],
  'shoes': [
    (category: 'shoes', desc: 'not bad'),
    (category: 'shoes', desc: 'great'),
  ],
};

const then2 = {
  'pants': [
    (category: 'pants', desc: 'bad'),
    (category: 'pants', desc: 'good'),
  ],
  'shoes': [
    (category: 'shoes', desc: 'not bad'),
    (category: 'shoes', desc: 'great'),
  ],
};

enum Status { todo, inProgress, done }

void main() {
  group('groupBy', () {
    group('sync', () {
      test("should be grouped by callback to given 'Iterable'", () {
        final res = groupBy((Obj a) => a.category, given);
        expect(res, equals(then1));
      });

      test('should be able to be used in the pipeline', () {
        final res = groupBy((Obj a) => a.category,
            filter((Obj a) => a.category != 'clothes', given));
        expect(res, equals(then2));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx(given)
            .filter((a) => a.category != 'clothes')
            .groupBy((a) => a.category);
        expect(res, equals(then2));
      });
    });

    group('async', () {
      test("should be grouped by the callback to given 'AsyncIterable'",
          () async {
        final res = await groupByAsync((Obj a) => a.category, toAsync(given));
        expect(res, equals(then1));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await groupByAsync((Obj a) => a.category,
            filterAsync((Obj a) => a.category != 'clothes', toAsync(given)));
        expect(res, equals(then2));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fx(given)
            .toAsync()
            .filter((a) => a.category != 'clothes')
            .groupBy((a) => a.category);
        expect(res, equals(then2));
      });
    });

    group('enum and union types (Issue #233)', () {
      test('should work with enum keys in entries + fold pattern', () {
        final tasks = [
          (id: 1, status: Status.todo, priority: 3),
          (id: 2, status: Status.inProgress, priority: 5),
          (id: 3, status: Status.done, priority: 1),
          (id: 4, status: Status.todo, priority: 2),
        ];

        final result = fromEntries(fx(entries(groupBy((t) => t.status, tasks)))
            .map((e) =>
                (e.$1, fold(0, (int sum, item) => sum + item.priority, e.$2)))
            .toArray());

        expect(
            result,
            equals({
              Status.todo: 5,
              Status.inProgress: 5,
              Status.done: 1,
            }));
      });

      test('should work with string keys aggregated per group', () {
        final items = [
          (name: 'apple', color: 'red', value: 10),
          (name: 'grass', color: 'green', value: 20),
          (name: 'sky', color: 'blue', value: 30),
          (name: 'rose', color: 'red', value: 15),
        ];

        final result = fx(entries(groupBy((item) => item.color, items)))
            .map((e) => (
                  color: e.$1,
                  total: fold(0, (int sum, item) => sum + item.value, e.$2),
                  count: e.$2.length,
                ))
            .toArray();

        expect(
            result,
            equals([
              (color: 'red', total: 25, count: 2),
              (color: 'green', total: 20, count: 1),
              (color: 'blue', total: 30, count: 1),
            ]));
      });

      test('should handle numeric keys', () {
        const pending = 0;
        const active = 1;

        final data = [
          (id: 1, status: pending),
          (id: 2, status: active),
          (id: 3, status: pending),
        ];

        final result = groupBy((item) => item.status, data);

        expect(
            result,
            equals({
              pending: [
                (id: 1, status: pending),
                (id: 3, status: pending),
              ],
              active: [
                (id: 2, status: active),
              ],
            }));
      });

      test('should work with async callback', () async {
        final items = [
          (name: 'task1', priority: 'low'),
          (name: 'task2', priority: 'high'),
          (name: 'task3', priority: 'low'),
        ];

        final result =
            await groupByAsync((item) async => item.priority, toAsync(items));

        expect(
            result,
            equals({
              'low': [
                (name: 'task1', priority: 'low'),
                (name: 'task3', priority: 'low'),
              ],
              'high': [
                (name: 'task2', priority: 'high'),
              ],
            }));
      });
    });
  });
}
