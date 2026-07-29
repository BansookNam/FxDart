import 'package:fxdart/fxdart.dart';

void main() {
  // mapOrAccumulate: validate a whole collection fail-slow — every bad
  // element is reported, good ones are only kept if ALL succeed.
  final bad = either<Nel<String>, List<int>>((r) => r.mapOrAccumulate(
      ['1', 'x', '3', 'y'],
      (r, s) =>
          r.ensureNotNull(int.tryParse(s), () => '"$s" is not a number')));
  print(bad); // Left(["x" is not a number, "y" is not a number])

  final ok = either<Nel<String>, List<int>>((r) => r.mapOrAccumulate(
      ['1', '2', '3'],
      (r, s) =>
          r.ensureNotNull(int.tryParse(s), () => '"$s" is not a number')));
  print(ok); // Right([1, 2, 3])

  // toEitherNel bridges a fail-fast Either into an accumulating scope;
  // bindNel unwraps it, raising all of its errors at once.
  const Either<String, int> failFast = Left('boom');
  final bridged =
      either<Nel<String>, int>((r) => r.bindNel(failFast.toEitherNel()));
  print(bridged); // Left([boom])
}
