import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // fromStream() lifts any Stream into an FxAsyncIterable.
  final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
  final doubled = await toArrayAsync(mapAsync((a) => a * 2, fromStream(stream)));
  print(doubled); // [2, 4, 6, 8, 10]

  // fxStream() does the same but hands back a chainable FxAsync directly.
  final chained = await fxStream(Stream.fromIterable([1, 2, 3, 4, 5]))
      .filter((a) => a.isOdd)
      .toArray();
  print(chained); // [1, 3, 5]
}
