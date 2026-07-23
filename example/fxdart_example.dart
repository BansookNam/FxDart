import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Lazy, typed pipelines with the fx chain (the Dart analogue of FxTS pipe).
  final evens = fx([1, 2, 3, 4, 5])
      .map((a) => a + 10)
      .filter((a) => a % 2 == 0)
      .toList();
  print(evens); // [12, 14]

  // Everything stays lazy until a terminal operator runs.
  final firstThreeSquares =
      fx(range(1, 100)).map((a) => a * a).take(3).toList();
  print(firstThreeSquares); // [1, 4, 9]

  // Top-level data-first functions compose too.
  print(toList(chunk(2, range(5)))); // [[0, 1], [2, 3], [4]]
  print(groupBy((int a) => a % 2 == 0 ? 'even' : 'odd', [1, 2, 3, 4]));
  // {odd: [1, 3], even: [2, 4]}

  // Async pipelines: toAsync lifts an Iterable (of values or Futures) into
  // an FxAsyncIterable; callbacks may be async.
  final asyncResult = await fx([1, 2, 3, 4])
      .toAsync()
      .map((a) async => a + 10)
      .filter((a) => a % 2 == 0)
      .toList();
  print(asyncResult); // [12, 14]

  // concurrent(n) evaluates the upstream chain n items at a time —
  // 6 requests of ~200ms finish in ~400ms instead of ~1200ms.
  final stopwatch = Stopwatch()..start();
  final fetched = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .map((id) => delay(const Duration(milliseconds: 200), 'user$id'))
      .concurrent(3)
      .toList();
  print('$fetched in ${stopwatch.elapsedMilliseconds}ms');

  // Streams bridge in and out.
  final doubled = await fxStream(Stream.fromIterable([1, 2, 3]))
      .map((a) => a * 2)
      .toList();
  print(doubled); // [2, 4, 6]
}
