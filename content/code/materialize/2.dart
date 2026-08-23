import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Pull / sync — fx([1, 2]).sequenceEqual([1, 2])
  print(fx([1, 2]).sequenceEqual([1, 2])); // true
  print(fx([1, 2]).sequenceEqual([1, 9])); // false
  print(fx([1, 2]).sequenceEqual([1])); // false — length mismatch

  // Pull / async
  print(await fx([1, 2]).toAsync().sequenceEqual(toAsync([1, 2]))); // true

  // Push / events — same values, same order, complete together.
  print(
    await fxEvents(
      Stream.fromIterable([1, 2]),
    ).sequenceEqual(Stream.fromIterable([1, 2])),
  ); // true
  print(
    await fxEvents(
      Stream.fromIterable([1, 2]),
    ).sequenceEqual(Stream.fromIterable([1, 9])),
  ); // false

  // Events partition: one source run, two chains. Listen to both
  // before the source fires — a side nobody is listening to is dropped.
  final (evens, odds) = fxEvents(
    Stream.fromIterable([1, 2, 3, 4]),
  ).partition((n) => n.isEven);
  final evenF = evens.toList();
  final oddF = odds.toList();
  print(await evenF); // [2, 4]
  print(await oddF); // [1, 3]
}
