import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  final total = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .map((a) => delay(const Duration(milliseconds: 150), a))
      .concurrent(3)
      .reduce((acc, a) => acc + a);

  print(total); // 21
  print('took ${sw.elapsedMilliseconds}ms');
}
