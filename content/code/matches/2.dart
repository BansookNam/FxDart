import 'package:fxdart/fxdart.dart';

void main() {
  final users = [
    {'name': 'kim', 'active': true},
    {'name': 'lee', 'active': false},
  ];

  // TODO: use matches to build a predicate for {'active': true} and filter with it
  final activeUsers = users;

  print(activeUsers);
}
