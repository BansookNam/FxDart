import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // There is no chain member: on Fx, join() with no separator is the
  // same thing — Iterable.join, whose default separator is ''.
  print(fx(['ab', 'cd', 'ef']).join()); // abcdef

  // There is no async twin either, and FxAsync.join defaults to ','.
  // Spell the empty separator out:
  final chain = fx(['ab', 'cd', 'ef']).toAsync();
  print(await chain.join('')); // abcdef

  // A large concatenation, built in one pass:
  final big = fxSumStrings(List.filled(20000, '0123456789'));
  print(big.length); // 200000
}
