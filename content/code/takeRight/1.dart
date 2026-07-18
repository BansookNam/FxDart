import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // takeRight must see the whole source before it can know the last N —
  // it materializes it first, so it only works on finite async sources.
  final result = await fx([1, 2, 3, 4, 5])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 50), a * a))
      .takeRight(2)
      .toArray();

  print(result); // [16, 25]
}
