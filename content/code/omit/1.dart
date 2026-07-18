import 'package:fxdart/fxdart.dart';

void main() {
  final users = [
    {'id': 1, 'name': 'kim', 'ssn': '111-11'},
    {'id': 2, 'name': 'lee', 'ssn': '222-22'},
  ];

  final redacted = fx(users).map((u) => omit(['ssn'], u)).toArray();
  print(redacted); // [{id: 1, name: kim}, {id: 2, name: lee}]

  // Omitting a key that doesn't exist is a no-op:
  print(omit(['nickname'], users[0])); // {id: 1, name: kim, ssn: 111-11}
}
