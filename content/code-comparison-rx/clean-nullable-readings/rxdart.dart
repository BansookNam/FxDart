import 'package:rxdart/rxdart.dart';

// Battery voltage samples — the sensor dropped three of them.
const List<double?> samples = [3.4, null, 3.9, 4.1, null, 3.7, null, 4.4, 4.0];

Future<void> main() async {
  // whereNotNull narrows Stream<double?> to Stream<double>.
  final clean = await Stream.fromIterable(samples)
      .whereNotNull()
      .map((v) => '${v.toStringAsFixed(1)} V')
      .toList();

  clean.forEach(print);
  print('Dropped ${samples.length - clean.length} empty samples');
}
