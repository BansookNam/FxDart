import 'package:fxdart/fxdart.dart';

void main() {
  final scores = {'alice': 92, 'bob': 41, 'carol': 78};

  print(omitBy((e) => e.$2 < 60, scores));    // {alice: 92, carol: 78}
  print(omitBy((e) => e.$1 == 'bob', scores)); // {alice: 92, carol: 78}
}
