import 'package:fxdart/fxdart.dart';

void main() {
  final users = [
    {'id': 1, 'name': 'ann'},
    {'id': 2, 'name': 'bob'},
    {'id': 1, 'name': 'ann-updated'}, // duplicate id
  ];

  // Data-first form: last duplicate wins, earlier ones are overwritten.
  final byId = indexBy((u) => u['id'], users);
  print(byId);
  // {1: {id: 1, name: ann-updated}, 2: {id: 2, name: bob}}

  // Chain form:
  final byParity = fx([1, 2, 3, 4]).indexBy((a) => a.isEven ? 'even' : 'odd');
  print(byParity); // {odd: 3, even: 4} -- last odd/even value wins
}
