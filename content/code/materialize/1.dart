import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Pass a clock so the stamp is deterministic (tests, playgrounds).
  final stamped = await fxEvents(
    Stream.fromIterable([1, 2, 3]),
  ).timestamped(now: () => DateTime.utc(2020)).toList();
  print(stamped);
  // [(2020-01-01 00:00:00.000Z, 1), (2020-01-01 00:00:00.000Z, 2), (2020-01-01 00:00:00.000Z, 3)]

  // intervals: first dt is always zero; later dts are the gap since the last.
  var t = DateTime.utc(2020);
  final spaced = await fxEvents(Stream.fromIterable(['a', 'b', 'c']))
      .intervals(
        now: () {
          final n = t;
          t = t.add(const Duration(milliseconds: 40));
          return n;
        },
      )
      .toList();
  print(spaced);
  // [(0:00:00.000000, a), (0:00:00.040000, b), (0:00:00.040000, c)]
}
