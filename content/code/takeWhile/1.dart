import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await fx([1, 2, 3, 8, 4])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 50), a))
      .takeWhile((a) => a < 5)
      .toArray();

  print(result); // [1, 2, 3]
}
