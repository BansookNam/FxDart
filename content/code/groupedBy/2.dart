import 'package:fxdart/fxdart.dart';

void main() {
  final entries = [
    (cat: 'food', amount: 25.0),
    (cat: 'transport', amount: 60.0),
    (cat: 'food', amount: 40.0),
    (cat: 'fun', amount: 30.0),
  ];

  // TODO: find the category with the highest total — one chain:
  // groupedBy → map to (key, total) → maxBy. No Map.entries anywhere.
  final top = ('?', 0.0);

  print('${top.$1} spent most: ${top.$2}'); // should print: food spent most: 65.0
}
