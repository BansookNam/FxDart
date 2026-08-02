import 'package:rxdart/rxdart.dart';

// One user session's events, already collected in order.
const events = [
  '09:12 login kim',
  '09:14 open /reports',
  '09:26 edit budget-aug',
  '09:41 logout kim',
];

Future<void> main() async {
  final lines = await Stream.fromIterable(events)
      .startWith('== SESSION OPEN ==')
      .endWith('== SESSION CLOSE ==')
      .toList();

  lines.forEach(print);
}
