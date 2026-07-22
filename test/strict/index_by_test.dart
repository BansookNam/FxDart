import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

typedef Obj = ({String category, String desc});

const given = <Obj>[
  (category: 'clothes', desc: 'good'),
  (category: 'pants', desc: 'bad'),
  (category: 'shoes', desc: 'not bad'),
];

const then1 = {
  'clothes': (category: 'clothes', desc: 'good'),
  'pants': (category: 'pants', desc: 'bad'),
  'shoes': (category: 'shoes', desc: 'not bad'),
};

const then2 = {
  'pants': (category: 'pants', desc: 'bad'),
  'shoes': (category: 'shoes', desc: 'not bad'),
};

enum UserRole { admin, user, guest }

void main() {
  group('indexBy', () {
    group('sync', () {
      test("should be grouped index by the callback to given 'Iterable'", () {
        final res = indexBy((Obj a) => a.category, given);
        expect(res, equals(then1));
      });

      test('should be able to be used in the pipeline', () {
        final res = indexBy((Obj a) => a.category,
            filter((Obj a) => a.category != 'clothes', given));
        expect(res, equals(then2));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx(given)
            .filter((a) => a.category != 'clothes')
            .indexBy((a) => a.category);
        expect(res, equals(then2));
      });
    });

    group('async', () {
      test("should be grouped index by the callback to given 'AsyncIterable'",
          () async {
        final res = await indexByAsync((Obj a) => a.category, toAsync(given));
        expect(res, equals(then1));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await indexByAsync((Obj a) => a.category,
            filterAsync((Obj a) => a.category != 'clothes', toAsync(given)));
        expect(res, equals(then2));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fx(given)
            .toAsync()
            .filter((a) => a.category != 'clothes')
            .indexBy((a) => a.category);
        expect(res, equals(then2));
      });
    });

    group('enum and union types', () {
      test('should work with enum keys, last value wins', () {
        final users = [
          (id: 1, name: 'Alice', role: UserRole.admin),
          (id: 2, name: 'Bob', role: UserRole.user),
          (id: 3, name: 'Charlie', role: UserRole.user), // overwrites Bob
          (id: 4, name: 'Dave', role: UserRole.guest),
        ];

        final usersByRole = indexBy((user) => user.role, users);

        final entriesResult = fx(entries(usersByRole))
            .map((e) => (role: e.$1, userName: e.$2.name, userId: e.$2.id))
            .toList();

        expect(
            entriesResult,
            equals([
              (role: UserRole.admin, userName: 'Alice', userId: 1),
              (role: UserRole.user, userName: 'Charlie', userId: 3),
              (role: UserRole.guest, userName: 'Dave', userId: 4),
            ]));

        final roles = usersByRole.keys.toList();
        expect(roles, equals([UserRole.admin, UserRole.user, UserRole.guest]));

        final names = usersByRole.values.map((u) => u.name).toList()..sort();
        expect(names, equals(['Alice', 'Charlie', 'Dave']));
      });

      test('should work with string keys, last value wins', () {
        final tasks = [
          (id: 1, title: 'Task 1', priority: 'low'),
          (id: 2, title: 'Task 2', priority: 'high'),
          (id: 3, title: 'Task 3', priority: 'medium'),
          (id: 4, title: 'Task 4', priority: 'high'), // overwrites Task 2
        ];

        final tasksByPriority = indexBy((task) => task.priority, tasks);

        final result = fx(entries(tasksByPriority))
            .map((e) => (
                  priority: e.$1,
                  taskTitle: e.$2.title,
                  isHighPriority: e.$1 == 'high',
                ))
            .toList();

        expect(
            result,
            equals([
              (priority: 'low', taskTitle: 'Task 1', isHighPriority: false),
              (priority: 'high', taskTitle: 'Task 4', isHighPriority: true),
              (priority: 'medium', taskTitle: 'Task 3', isHighPriority: false),
            ]));
      });

      test('should handle numeric keys', () {
        const pending = 0;
        const active = 1;

        final items = [
          (id: 1, status: pending),
          (id: 2, status: active),
          (id: 3, status: pending), // overwrites first pending
        ];

        final result = indexBy((item) => item.status, items);

        expect(
            result,
            equals({
              pending: (id: 3, status: pending),
              active: (id: 2, status: active),
            }));
        expect(result.keys.length, equals(2));
      });

      test('should work with async callback', () async {
        final items = [
          (name: 'item1', status: 'active'),
          (name: 'item2', status: 'inactive'),
          (name: 'item3', status: 'active'), // overwrites item1
        ];

        final result =
            await indexByAsync((item) async => item.status, toAsync(items));

        expect(
            result,
            equals({
              'active': (name: 'item3', status: 'active'),
              'inactive': (name: 'item2', status: 'inactive'),
            }));
      });
    });
  });
}
