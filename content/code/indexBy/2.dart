import 'package:fxdart/fxdart.dart';

void main() {
  final users = [
    {'id': 'u1', 'name': 'ann'},
    {'id': 'u2', 'name': 'bob'},
    {'id': 'u3', 'name': 'cid'},
  ];

  // TODO: index the users BY THEIR id, so you can look one up directly.
  final byId = fx(users).groupBy((u) => u['name']);

  print(byId);
}
