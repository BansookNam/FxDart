import 'package:fxdart/fxdart.dart';

void main() {
  final rows = [
    {'id': 1, 'name': 'kim', 'temp': 'x'},
    {'id': 2, 'name': 'lee', 'temp': 'y'},
  ];

  final slim = fx(rows).map((r) => pick(['id', 'name'], r)).toList();
  print(slim); // [{id: 1, name: kim}, {id: 2, name: lee}]
}
