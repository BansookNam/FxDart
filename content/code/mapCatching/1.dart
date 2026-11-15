import 'package:fxdart/fxdart.dart';

/// A lookup where id 3 is down.
Future<String> fetchName(int id) async {
  await Future.delayed(const Duration(milliseconds: 20));
  if (id == 3) throw StateError('service down');
  return 'user-$id';
}

Future<void> main() async {
  // Async: f and onError may both await. Under concurrent(2) each
  // in-flight element recovers on its own, and order is kept.
  final names = await fxAsync(
    fxToAsync([1, 2, 3, 4]),
  ).mapCatching(fetchName, (e, st) async => 'unknown').concurrent(2).toList();
  print(names); // [user-1, user-2, unknown, user-4]

  // A typed error is NOT recovered: r.raise crosses mapCatching and
  // still short-circuits the enclosing either block.
  final result = fxEither<String, List<int>>(
    (r) => fx([5, 0, 8])
        .mapCatching(
          (n) => n == 0 ? r.raise('zero is not allowed') : 100 ~/ n,
          (e, st) => -1,
        )
        .toList(), // materialize inside the block
  );
  print(result); // Left(zero is not allowed)
}
