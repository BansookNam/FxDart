import 'package:fxdart/fxdart.dart';

void main() {
  // TODO: build a 5-item List<int> of the value 7 using repeat.
  final sevens = fx(repeat(5, 7)).toArray();

  print(sevens); // [7, 7, 7, 7, 7]
}
