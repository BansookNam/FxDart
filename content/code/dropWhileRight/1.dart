import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final kept = await fxAsync(toAsync([1, 2, 0, 0]))
      .dropWhileRight((a) => a == 0)
      .toList();
  print(kept); // [1, 2]

  // The two split the source between them, with nothing lost or repeated.
  const source = [4, 1, 5, 9, 9];
  bool isNine(int a) => a == 9;
  print(fx(source).dropWhileRight(isNine).toList()); // [4, 1, 5]
  print(fx(source).takeWhileRight(isNine).toList()); // [9, 9]
}
