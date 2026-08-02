import 'package:fxdart/fxdart.dart';

// One user session's events, already collected in order.
const events = [
  '09:12 login kim',
  '09:14 open /reports',
  '09:26 edit budget-aug',
  '09:41 logout kim',
];

void main() {
  final lines = fx(events)
      .prepend('== SESSION OPEN ==')
      .append('== SESSION CLOSE ==')
      .toList();

  lines.forEach(print);
}
