import 'package:fxdart/fxdart.dart';

void main() {
  final scoreGroups = [
    [90, 85],
    [77, [95, 60]],
  ];

  // TODO: use flattened() to flatten scoreGroups by one level.
  final scores = fx(scoreGroups).toList();

  print(scores);
}
