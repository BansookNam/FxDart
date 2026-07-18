import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // sizeAsync / .toAsync().size() still has to pull every element to count them.
  final count = await fx(['a', 'bb', 'ccc', 'd'])
      .toAsync()
      .filter((s) => delay(const Duration(milliseconds: 100), s.length > 1))
      .size();

  print(count); // 2
}
