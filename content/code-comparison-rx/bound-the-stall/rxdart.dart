import 'package:rxdart/rxdart.dart';

/// Four probe reads; the third stalls far past the 150 ms budget.
const readMs = [30, 40, 500, 30];
const probeValues = [21.5, 21.7, 22.4, 21.9];

Future<double> readProbe(int i) async {
  await Future<void>.delayed(Duration(milliseconds: readMs[i]));
  return probeValues[i];
}

Future<void> main() async {
  final lines = await Stream.fromIterable([0, 1, 2, 3])
      // The budget is per read, so bound the Future itself. (The stream-
      // level .timeout operator measures a different thing: gaps between
      // events on the push side.)
      .asyncMap((i) =>
          readProbe(i).timeout(const Duration(milliseconds: 150)))
      .map((v) => 'reading: ${v.toStringAsFixed(1)}')
      // Replace the timeout error with a report line…
      .onErrorReturnWith((_, _) => 'reading timed out')
      // …and stop there: the paused source would otherwise resume pushing
      // readings once the stalled read finally lands.
      .takeWhileInclusive((line) => line != 'reading timed out')
      .toList();

  lines.forEach(print);
}
