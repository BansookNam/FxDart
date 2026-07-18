import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  final result = await fx([1, 2, 3])
      .toAsync()
      .map((n) => delay(Duration(milliseconds: 150), n * 10))
      .concurrent(3)
      .toArray();

  print(result); // [10, 20, 30]
  print('took < 300ms: ${sw.elapsedMilliseconds < 300}'); // true
}
