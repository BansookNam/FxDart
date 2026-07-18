import 'package:fxdart/fxdart.dart';

void main() {
  final scores = {'alice': 92, 'bob': 41, 'carol': 78};
  print(pickBy((e) => e.$2 >= 60, scores)); // {alice: 92, carol: 78}
}
