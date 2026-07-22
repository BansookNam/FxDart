import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final left = fx([1, 2]).toAsync().map((a) => delay(Duration(milliseconds: 50), a));
  final right = fx([3, 4]).toAsync().map((a) => delay(Duration(milliseconds: 50), a));

  final result = await left.concat(right).toList();
  print(result); // [1, 2, 3, 4]
}
