import 'package:fxdart/fxdart.dart';

void main() {
  // Any Iterable → Nel?, straight off a pipeline — no .toList() shuffle:
  final problems = fx(['ok', 'bad row 2', 'ok', 'bad row 7'])
      .filter((line) => line.startsWith('bad'))
      .toNelOrNull();
  print(problems?.head); // bad row 2

  // Empty stays null — "no errors" and "an error panel" share one type:
  final clean =
      fx(['ok', 'fine']).filter((l) => l.startsWith('bad')).toNelOrNull();
  print(clean); // null

  // It agrees with Nel.orNull, minus the ceremony:
  print(Nel.orNull(<String>[])); // null
  print(<int>[1, 2].toNelOrNull()?.toList()); // [1, 2]

  // was: Nel.orNull(problems.toList())
}
