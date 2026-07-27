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
  // Manual windowing: buffer 4 readings, flush, repeat.
  final windows = <(String, double, double)>[];
  var buf = <Reading>[];
  await for (final r in sensor()) {
    buf.add(r);
    if (buf.length == 4) {
      final avg =
          buf.fold(0.0, (sum, r) => sum + r.c) / buf.length;
      final peak = buf.map((r) => r.c).reduce((a, b) => a > b ? a : b);
      windows.add(('${buf.first.second}s-${buf.last.second}s', avg, peak));
      buf = [];
    }
  }
  print('boiler sensor, windows of 4 readings:');
  for (final (span, avg, peak) in windows) {
    print('  $span  avg ${avg.toStringAsFixed(2)}  '
        'peak ${peak.toStringAsFixed(1)}');
  }
  for (final w in windows.where((w) => w.$2 >= 75.0)) {
    print('ALERT ${w.$1}: average ${w.$2.toStringAsFixed(2)} '
        'is above the 75.00 limit');
  }
}
