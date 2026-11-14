import 'package:fxdart/fxdart.dart';

void main() {
  final latencies = [120, 80, 95, 300, 110, 90, 85, 100, 105, 700];

  // TODO: replace the sort-and-index with fxQuantile(0.9, latencies).
  final sorted = [...latencies]..sort();
  final p90 = sorted[((sorted.length - 1) * 0.9).round()];

  print('p90 = $p90 ms'); // should print: p90 = 300 ms
}
