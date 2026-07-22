import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // toAsync() lifts a plain Iterable of values into an FxAsyncIterable.
  final justValues = toAsync([1, 2, 3]);
  print(await toListAsync(justValues)); // [1, 2, 3]

  // It also accepts an Iterable<FutureOr<T>> — any Future elements are
  // awaited as they're pulled.
  final mixedFutures = toAsync([
    delay(const Duration(milliseconds: 50), 10),
    20,
    delay(const Duration(milliseconds: 50), 30),
  ]);
  print(await toListAsync(mixedFutures)); // [10, 20, 30]

  // Chain form: fx(iterable).toAsync()
  final chained = await fx([1, 2, 3]).toAsync().map((a) => a * 2).toList();
  print(chained); // [2, 4, 6]
}
