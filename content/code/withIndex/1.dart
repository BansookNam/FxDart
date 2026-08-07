import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final rows = ['a', 'b', 'c', 'd'];

  // The index counts the INPUT, so dropped elements still advance it.
  print(fx(rows).filterWithIndex((row, i) => i.isEven).toList()); // [a, c]

  print(fx(rows).flatMapWithIndex((row, i) => List.filled(i, row)).toList());
  // [b, c, c, d, d, d]

  print(fx([10, 20, 30]).foldWithIndex<int>(0, (acc, a, i) => acc + a * i));
  // 80

  // Async too, and the numbering stays in source order under concurrent.
  final numbered = await fxAsync(toAsync(rows))
      .mapWithIndex((row, i) => '$i$row')
      .toList();
  print(numbered); // [0a, 1b, 2c, 3d]
}
