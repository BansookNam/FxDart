import 'package:fxdart/fxdart.dart';

void main() {
  // TODO: cycle through these traffic-light colors and take the first 8.
  final colors = ['red', 'yellow', 'green'];

  final sequence = fx(colors).cycle().take(8).toArray();

  print(sequence); // [red, yellow, green, red, yellow, green, red, yellow]
}
