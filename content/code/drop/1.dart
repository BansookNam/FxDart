import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  final result = await fx(range(6))
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 100), a))
      .concurrent(3)
      .skip(2) // FxTS alias: .drop(2)
      .toList();

  print(result); // [2, 3, 4, 5]
  print('took ${sw.elapsedMilliseconds}ms');
}
