import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // toArrayAsync / .toArray() awaits every element, then hands back a List.
  final result = await fx([1, 2, 3, 4])
      .toAsync()
      .map((a) => delay(const Duration(milliseconds: 100), a * 10))
      .concurrent(4)
      .toArray();

  print(result); // [10, 20, 30, 40]
  print(sw.elapsedMilliseconds < 300); // true — ran concurrently
}
