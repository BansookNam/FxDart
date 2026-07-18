import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // The appended value may itself be a Future:
  final result = await fx([1, 2, 3])
      .toAsync()
      .append(delay(Duration(milliseconds: 50), 4))
      .toArray();

  print(result); // [1, 2, 3, 4]
}
