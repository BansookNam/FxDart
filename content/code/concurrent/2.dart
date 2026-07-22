import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final items = [1, 2, 3, 4, 5, 6];
  final sw = Stopwatch()..start();

  // TODO: tune the concurrency `n` below. With 6 items of 200ms each:
  //   n=1 (sequential) takes ~1200ms, n=3 takes ~400ms, n=6 takes ~200ms.
  // Try n=6 and see the elapsed time drop.
  final n = 1;

  final result = await fx(items)
      .toAsync()
      .map((a) => delay(const Duration(milliseconds: 200), a))
      .concurrent(n)
      .toList();

  print(result); // [1, 2, 3, 4, 5, 6]
  print('n=$n took ${sw.elapsedMilliseconds}ms');
}
