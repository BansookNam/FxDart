import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await fx([1, 2, 3, 4, 5])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 50), a))
      .dropUntil((a) => a == 3)
      .toList();

  print(result); // [4, 5]
}
