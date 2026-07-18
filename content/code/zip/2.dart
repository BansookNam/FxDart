import 'package:fxdart/fxdart.dart';

void main() {
  final names = ['kim', 'lee', 'park'];
  final ages = [32, 27, 41];

  // TODO: zip names and ages together into (name, age) records
  final people = fx(names).toArray();

  print(people);
}
