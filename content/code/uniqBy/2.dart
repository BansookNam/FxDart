import 'package:fxdart/fxdart.dart';

void main() {
  final events = [
    {'type': 'click', 'id': 1},
    {'type': 'click', 'id': 2},
    {'type': 'scroll', 'id': 3},
  ];

  // TODO: use uniqBy to keep only the first event of each 'type'.
  final result = fx(events).toArray();

  print(result);
}
