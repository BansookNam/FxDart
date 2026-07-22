import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await fx([2, 3, 4])
      .toAsync()
      .prepend(delay(Duration(milliseconds: 50), 1))
      .toList();

  print(result); // [1, 2, 3, 4]
}
