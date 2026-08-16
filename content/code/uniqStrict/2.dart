import 'package:fxdart/fxdart.dart';

void main() {
  final visits = [
    ('ann', '09:01'),
    ('bob', '09:04'),
    ('ann', '09:20'),
    ('cid', '09:31'),
    ('bob', '09:40'),
  ];

  // TODO: use uniqByStrict to keep each visitor's FIRST visit, as a List you
  // can index and take a length from without iterating again.
  final firstVisits = visits;

  print(firstVisits.length); // want: 3
  print(firstVisits.first); // want: (ann, 09:01)
}
