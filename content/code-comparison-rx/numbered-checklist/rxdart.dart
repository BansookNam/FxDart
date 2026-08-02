import 'package:rxdart/rxdart.dart';

// Setup steps for the new sensor kit, in order.
const steps = [
  'Unbox the sensor kit',
  'Charge the base station',
  'Pair the remote',
  'Mount the wall bracket',
  'Run the self-test',
  'Register the warranty',
];

Future<void> main() async {
  // Streams have no indexed map. The closest rxdart gets is scan, whose
  // accumulator receives an index — so the numbering rides a fold with a
  // throwaway seed and an ignored accumulator.
  final numbered = await Stream.fromIterable(steps)
      .scan<String>((_, step, i) => '${i + 1}. $step', '')
      .toList();

  numbered.forEach(print);
}
