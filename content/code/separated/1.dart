import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // separated() splits both halves at once — the Either shape of
  // partition, and the events twin of FxEitherOps.separated.
  final (failures, successes) = fxEvents(
    Stream.fromIterable(<Either<String, int>>[
      const Right(1),
      const Left('a'),
      const Right(2),
    ]),
  ).separated();

  // Listen to both halves before awaiting either — a value belonging
  // to a side nobody is listening to is dropped, not buffered.
  final numbers = successes.toList();
  final errs = failures.toList();
  print(await numbers); // [1, 2]
  print(await errs); // [a]
}
