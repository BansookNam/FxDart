import 'package:fxdart/fxdart.dart';

Either<String, List<int>> lazy() => either((r) {
  // expect_lint: avoid_lazy_return_from_raise
  return fx([1, 2, 3]).map((n) {
    r.ensure(n > 0, () => 'neg');
    return n;
  });
});

Either<String, Iterable<int>> justFx() => either((r) {
  r.ensure(true, () => 'no');
  // expect_lint: avoid_lazy_return_from_raise
  return fx([1, 2, 3]);
});

Either<String, List<int>> materialized() => either((r) {
  return fx([1, 2, 3]).map((n) {
    r.ensure(n > 0, () => 'neg');
    return n;
  }).toList();
});

Either<String, Either<String, List<int>>> sequenced() => either((r) {
  return fx([Either<String, int>.right(1)]).sequence();
});

Either<String, Iterable<int>> arrowLazy() => either(
  (r) =>
      // expect_lint: avoid_lazy_return_from_raise
      fx([1, 2, 3]).map((n) {
        r.ensure(n > 0, () => 'neg');
        return n;
      }),
);

Either<String, List<int>> arrowMaterialized() => either(
  (r) => fx([1, 2, 3]).map((n) {
    r.ensure(n > 0, () => 'neg');
    return n;
  }).toList(),
);

Either<String, List<Iterable<int>>> nested() => either((r) {
  return fx([1, 2, 3]).map((n) {
    return fx([n]).map((m) => m * 2);
  }).toList();
});
