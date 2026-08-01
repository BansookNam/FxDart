import 'package:fxdart/fxdart.dart';

Either<String, int> parse(String s) =>
    either((r) => r.ensureNotNull(int.tryParse(s), () => 'bad: $s'));

void main() async {
  final verdicts = fx(['1', 'x', '3', 'y']).map(parse).toList();

  // sequence stops at the FIRST Left; flattenOrAccumulate keeps walking
  // and reports EVERY failure (Arrow's name, Arrow's semantics):
  print(fx(verdicts).sequence()); // Left(bad: x)
  print(fx(verdicts).flattenOrAccumulate()); // Left([bad: x, bad: y])

  // was: fx(verdicts).mapOrAccumulate((r, v) => r.bind(v))

  // All-good input collects every value:
  print(fx(['1', '2']).map(parse).flattenOrAccumulate()); // Right([1, 2])

  // The async chain has the full extract family now — the "47 ok ·
  // 3 problems" badge over an async validation is one terminal:
  final (bad, good) =
      await fx(['1', 'x', '3']).toAsync().map(parse).separated();
  print('${good.length} ok · ${bad.length} problems'); // 2 ok · 1 problems

  // Only one side needed? Skip allocating the pair:
  print(await fx(['1', 'x', '3']).toAsync().map(parse).rights()); // [1, 3]
}
