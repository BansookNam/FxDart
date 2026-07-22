import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await fx([10, 20, 30, 40, 50])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 50), a))
      .slice(1, 4)
      .toList();

  print(result); // [20, 30, 40]
}
