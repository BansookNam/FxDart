import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Works over the async chain too — still one walk, no sort:
  final shortest = await fx(['10', '200', '3'])
      .toAsync()
      .map((s) => delay(const Duration(milliseconds: 100), s))
      .minBy((s) => s.length);

  print(shortest); // 3
}
