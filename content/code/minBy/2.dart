import 'package:fxdart/fxdart.dart';

void main() {
  final runners = [
    (name: 'Ana', seconds: 62.1),
    (name: 'Ben', seconds: 58.4),
    (name: 'Cho', seconds: 60.0),
  ];

  // TODO: find the fastest runner (smallest seconds) with one minBy call.
  final fastest = fx(runners).head();

  print(fastest?.name); // should print: Ben
}
