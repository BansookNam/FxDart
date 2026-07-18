import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await fx([1, 2, 3])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 50), a * 10))
      .last();
  print(result); // 30

  print(await fxAsync(asyncEmpty<int>()).last()); // null
}
