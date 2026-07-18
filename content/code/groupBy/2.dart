import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['fig', 'kiwi', 'fx', 'plum', 'go', 'date'];

  // TODO: group the words BY THEIR LENGTH.
  final grouped = fx(words).groupBy((w) => w[0]);

  print(grouped);
}
