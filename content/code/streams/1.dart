import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Stream.periodic never ends on its own, so take(5) keeps this finite.
  final source =
      Stream.periodic(const Duration(milliseconds: 30), (i) => i).take(5);
  final squared = await fxStream(source).map((a) => a * a).toArray();
  print(squared); // [0, 1, 4, 9, 16]

  // Round-trip: build an FxAsync chain, then hand it back out as a Stream
  // with .toStream() for code that expects one (e.g. a widget builder).
  final roundTrip = fx([1, 2, 3]).toAsync().map((a) => a * 100).toStream();
  await for (final v in roundTrip) {
    print(v); // 100, 200, 300
  }
}
