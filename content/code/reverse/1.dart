import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Like takeRight, reverse must see the whole source, so it only works on
  // finite async sources — it buffers everything before yielding the first.
  final result = await fx([1, 2, 3, 4])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 50), a * 10))
      .reverse()
      .toList();

  print(result); // [40, 30, 20, 10]
}
