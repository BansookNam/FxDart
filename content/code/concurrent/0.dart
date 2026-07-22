import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final items = [1, 2, 3, 4, 5, 6];

  // Sequential: mapAsync awaits one 200ms delay after another.
  var sw = Stopwatch()..start();
  final sequential = await fx(items)
      .toAsync()
      .map((a) => delay(const Duration(milliseconds: 200), a * 10))
      .toList();
  print(sequential); // [10, 20, 30, 40, 50, 60]
  print('sequential: ${sw.elapsedMilliseconds}ms'); // ~1200ms

  // concurrent(3): a downstream marker asks the upstream `map` to evaluate
  // 3 elements at a time. Order is still preserved in the result.
  sw = Stopwatch()..start();
  final parallel = await fx(items)
      .toAsync()
      .map((a) => delay(const Duration(milliseconds: 200), a * 10))
      .concurrent(3)
      .toList();
  print(parallel); // [10, 20, 30, 40, 50, 60]
  print('concurrent(3): ${sw.elapsedMilliseconds}ms'); // ~400ms
}
