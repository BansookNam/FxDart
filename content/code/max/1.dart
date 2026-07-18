import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final highScore = await fx([120, 340, 210, 500, 90])
      .toAsync()
      .map((s) => delay(const Duration(milliseconds: 100), s))
      .max();

  print(highScore); // 500
}
