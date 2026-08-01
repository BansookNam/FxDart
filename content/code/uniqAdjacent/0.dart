import 'package:fxdart/fxdart.dart';

void main() {
  // A status feed that re-reports the same state every tick:
  final states = ['ok', 'ok', 'ok', 'warn', 'warn', 'ok', 'ok', 'down'];

  // Only the CHANGES survive — returns to an earlier state included:
  print(fx(states).uniqAdjacent().toList());
  // [ok, warn, ok, down]

  // Compare with uniq, which answers "ever seen?" instead of "changed?":
  print(fx(states).uniq().toList());
  // [ok, warn, down]        ← the return to 'ok' is lost

  // And no seen-set builds up: constant memory, safe on endless feeds.
}
