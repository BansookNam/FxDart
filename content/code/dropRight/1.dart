import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await fx([1, 2, 3, 4, 5])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 50), a * 10))
      .dropRight(2)
      .toList();

  print(result); // [10, 20, 30]
}
