import 'package:fxdart/fxdart.dart';

void main() {
  final inventory = [3, 0, 7, 0, 5, 0, 9];

  // TODO: count how many entries are OUT OF STOCK (value == 0).
  final count = fx(inventory).size();

  print(count);
}
