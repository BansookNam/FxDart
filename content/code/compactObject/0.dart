import 'package:fxdart/fxdart.dart';

void main() {
  final form = {'name': 'kim', 'nickname': null, 'age': 32, 'bio': null};
  print(compactObject(form)); // {name: kim, age: 32}
}
