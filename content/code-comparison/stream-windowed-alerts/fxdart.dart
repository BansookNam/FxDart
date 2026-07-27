import 'package:fxdart/fxdart.dart';

class Reading {
  final int second; // offset into the run
  final double c; // temperature in celsius
  const Reading(this.second, this.c);
}

const samples = [
  Reading(0, 68.0), Reading(1, 69.5), Reading(2, 70.0), Reading(3, 70.5),
  Reading(4, 74.0), Reading(5, 76.5), Reading(6, 77.0), Reading(7, 75.5),
  Reading(8, 72.0), Reading(9, 70.0), Reading(10, 69.0), Reading(11, 68.5),
];

/// The sensor: a real Dart Stream, one reading every 10 ms.
Stream<Reading> sensor() async* {
  for (final r in samples) {
    await Future.delayed(const Duration(milliseconds: 10));
    yield r;
  }
}

Future<void> main() async {
  final windows = await fxStream(sensor())
      .chunk(4)
      .map((w) => (
            '${w.first.second}s-${w.last.second}s',
            fx(w).averageBy((r) => r.c),
            fx(w).maxBy((r) => r.c)!.c,
          ))
      .toList();
  print('boiler sensor, windows of 4 readings:');
  for (final (span, avg, peak) in windows) {
    print('  $span  avg ${avg.toStringAsFixed(2)}  '
        'peak ${peak.toStringAsFixed(1)}');
  }
  for (final w in fx(windows).filter((w) => w.$2 >= 75.0)) {
    print('ALERT ${w.$1}: average ${w.$2.toStringAsFixed(2)} '
        'is above the 75.00 limit');
  }
}
