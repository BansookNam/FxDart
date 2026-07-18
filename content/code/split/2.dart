import 'package:fxdart/fxdart.dart';

void main() {
  const csv = 'red|green|blue';

  // TODO: use split to break csv into color names on '|'
  final colors = toArray(csv.split(''));

  print(colors);
}
