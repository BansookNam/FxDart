import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Every sync op has a data-first *Async twin that works on
  // FxAsyncIterable instead of Iterable.
  final doubled = await fxToListAsync(
      fxMapAsync((a) => a * 2, fxToAsync([1, 2, 3])));
  print(doubled); // [2, 4, 6]

  final evens = await fxToListAsync(
      fxFilterAsync((a) async => a.isEven, fxToAsync([1, 2, 3, 4, 5, 6])));
  print(evens); // [2, 4, 6]

  final total = await fxReduceAsync((acc, a) => acc + a, fxToAsync([1, 2, 3, 4]));
  print(total); // 10
}
