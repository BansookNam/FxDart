import 'package:fxdart/fxdart.dart';

void main() {
  final readings = [
    ('09:00', 18.4),
    ('10:00', 26.1),
    ('11:00', 31.7),
    ('12:00', 29.3),
    ('13:00', 22.0),
  ];

  // TODO: this walks the readings twice and builds a list it throws away.
  // Rewrite it as ONE chain ending in a single terminal operator.
  final hot = fx(readings).filter((r) => r.$2 > 25).toList();
  final labels = fx(hot).map((r) => '${r.$1}: ${r.$2}').toList();

  print(labels.length); // want: 3
  print(labels.first); // want: 10:00: 26.1
}
