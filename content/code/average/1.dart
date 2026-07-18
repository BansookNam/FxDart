import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final scores = await fx(['10', '20', '30'])
      .toAsync()
      .map((s) => delay(const Duration(milliseconds: 100), int.parse(s)))
      .average();

  print(scores); // 20.0
}
