import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Works over the async chain too — still one walk, no sort:
  final longest = await fx(['10', '200', '3'])
      .toAsync()
      .map((s) => delay(const Duration(milliseconds: 100), s))
      .maxBy((s) => s.length);

  print(longest); // 200
}
