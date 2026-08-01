import 'package:fxdart/fxdart.dart';

final failedOnce = <int>{};

/// A per-user lookup where even ids flake on their first call.
Future<String> fetchUser(int id) async {
  await Future.delayed(const Duration(milliseconds: 30));
  if (id.isEven && failedOnce.add(id)) throw Exception('flaky $id');
  return 'user-$id';
}

void main() async {
  final sw = Stopwatch()..start();

  // mapRetry gives EVERY element its own retry budget, and it is built on
  // the parallel-safe map — so under concurrent(3), a flaky element
  // re-runs while its neighbors keep going, and order is preserved:
  final users = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .mapRetry(3, fetchUser)
      .concurrent(3)
      .toList();

  print(users);
  // [user-1, user-2, user-3, user-4, user-5, user-6]
  print('retried: $failedOnce in ${sw.elapsedMilliseconds}ms');
  // retried: {2, 4, 6} — and still ~4 batch-times, not 9 sequential calls
}
