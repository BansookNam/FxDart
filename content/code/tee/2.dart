import 'package:fxdart/fxdart.dart';

void main() {
  var reads = 0;
  Iterable<int> sensor() sync* {
    for (final v in [10, 20, 30]) {
      reads++;
      yield v;
    }
  }

  // TODO: replace these two passes with one tee so the sensor is read only
  // once (`reads` should print 3, not 6).
  final total = sensor().fold<int>(0, (a, b) => a + b);
  final count = sensor().length;

  print('total: $total');
  print('count: $count');
  print('reads: $reads');
}
