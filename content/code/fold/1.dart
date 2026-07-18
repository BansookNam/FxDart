import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // foldAsync / FxAsync.fold(seed, f) build up a Map while pulling the pipeline.
  final histogram = await fx(['a', 'bb', 'c', 'dd', 'e'])
      .toAsync()
      .map((s) => delay(const Duration(milliseconds: 100), s))
      .fold<Map<int, int>>(<int, int>{}, (acc, s) {
    acc.update(s.length, (n) => n + 1, ifAbsent: () => 1);
    return acc;
  });

  print(histogram); // {1: 3, 2: 2}
}
