import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  final result = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 200), a * 10))
      .concurrent(3) // remove this line to see ~1200ms
      .toArray();

  print(result); // [10, 20, 30, 40, 50, 60]
  print('took ${sw.elapsedMilliseconds}ms');
}
