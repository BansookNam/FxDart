import 'package:fxdart/fxdart.dart';

void main() {
  final temps = [18.5, 21.0, 19.2, 23.8, 20.1];

  // TODO: replace the negated some with fx(temps).none(...),
  // which says "no reading is over 25" directly.
  final safe = !fx(temps).some((t) => t > 25);

  print(safe ? 'all clear' : 'overheat'); // should print: all clear
}
