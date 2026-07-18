import 'package:fxdart/fxdart.dart';

void main() {
  final user = {'id': 1, 'name': 'kim', 'password': 'secret'};
  print(omit(['password'], user)); // {id: 1, name: kim}
  print(user); // {id: 1, name: kim, password: secret} — original untouched
}
