import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Four probe reads; the third stalls far past the 150 ms budget.
const readMs = [30, 40, 500, 30];
const probeValues = [21.5, 21.7, 22.4, 21.9];

Future<double> readProbe(int i) async {
  await Future<void>.delayed(Duration(milliseconds: readMs[i]));
  return probeValues[i];
}

Future<void> main() async {
  final lines = <String>[];
  try {
    // Pull model: timeout bounds DEMAND-TO-ITEM time — the third pull
    // takes 500 ms to produce its reading, tripping the 150 ms limit.
    // Collect as we go: the readings before the stall are already kept
    // when the failing pull throws.
    await fx([0, 1, 2, 3])
        .toAsync()
        .map(readProbe)
        .timeout(const Duration(milliseconds: 150))
        .map((v) => 'reading: ${v.toStringAsFixed(1)}')
        .each(lines.add);
  } on TimeoutException {
    lines.add('reading timed out');
  }

  lines.forEach(print);
}
