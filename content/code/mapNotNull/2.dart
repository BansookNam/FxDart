import 'package:fxdart/fxdart.dart';

void main() {
  final answers = ['34', 'forty', '27', '', '61', 'n/a'];

  // TODO: this parses every valid answer twice. Replace the
  // where + map pair with one mapNotNull(int.tryParse).
  final ages = fx(answers)
      .where((s) => int.tryParse(s) != null)
      .map((s) => int.parse(s))
      .toList();

  print(ages); // should print: [34, 27, 61]
}
