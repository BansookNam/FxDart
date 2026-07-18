import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // take is a pass-through: concurrent(3) upstream still overlaps pulls
  // even though only 4 elements are ultimately taken.
  final result = await fx(range(10))
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 100), a * 10))
      .concurrent(3)
      .take(4)
      .toArray();

  print(result); // [0, 10, 20, 30]
  print('took ${sw.elapsedMilliseconds}ms'); // ~200ms, not 400ms
}
