import 'package:fxdart/fxdart.dart';

void main() {
  final queue = ['alice', 'bob', 'carol', 'dave', 'erin'];

  // TODO: take only the first 3 names from the queue
  final firstThree = fx(queue).toArray();

  print(firstThree);
}
