import 'package:fxdart/fxdart.dart';

void main() {
  final votes = ['cat', 'dog', 'cat', 'bird', 'dog', 'cat'];

  // TODO: count how many votes each candidate received.
  final tally = fx(votes).groupBy((v) => v);

  print(tally);
}
