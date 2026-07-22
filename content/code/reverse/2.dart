import 'package:fxdart/fxdart.dart';

void main() {
  final history = ['visited home', 'visited cart', 'visited checkout'];

  // TODO: reverse the history so the most recent visit comes first
  final mostRecentFirst = fx(history).toList();

  print(mostRecentFirst);
}
