import 'package:fxdart/fxdart.dart';

void main() {
  final scores = {'kim': 88, 'lee': 42, 'park': 95};

  // TODO: turn entries(scores) into a list of "name: PASS/FAIL" strings,
  // where >= 60 is a PASS.
  final report = fx(entries(scores))
      .map((e) => '${e.$1}: ${e.$2 >= 60 ? 'PASS' : 'FAIL'}')
      .toArray();

  report.forEach(print);
}
