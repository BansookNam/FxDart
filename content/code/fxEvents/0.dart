import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // fxEvents wraps a plain Stream in a chainable FxEvents. The chain is
  // cold — nothing runs until something listens (toList here).
  final out = await fxEvents(Stream.fromIterable([1, 2, 3, 4]))
      .startWith(0)
      .where((v) => v.isEven)
      .map((v) => v * 10)
      .asyncMap((v) async => 'v$v')
      .toList();

  print(out); // [v0, v20, v40]

  // .stream unwraps back to a plain Stream for any Stream-based API.
  final Stream<int> plain = fxEvents(Stream.fromIterable([1, 2, 3])).stream;
  print(await plain.length); // 3
}
