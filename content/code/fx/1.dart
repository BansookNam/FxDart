import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // fxAsync wraps an FxAsyncIterable (from toAsync/fromStream/*Async ops).
  final total = await fxAsync(toAsync([1, 2, 3]))
      .map((a) => delay(const Duration(milliseconds: 50), a * 10))
      .reduce((acc, a) => acc + a);
  print('fxAsync total: $total'); // 60

  // fxStream wraps a Dart Stream directly.
  final doubled = await fxStream(Stream.fromIterable([1, 2, 3]))
      .map((a) => a * 2)
      .toList();
  print('fxStream doubled: $doubled'); // [2, 4, 6]
}
