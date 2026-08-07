import 'package:fxdart/fxdart.dart';

bool isBlank(String s) => s.trim().isEmpty;
bool isShort(String s) => s.length < 3;

void main() {
  final rows = ['  ', 'ok', 'fine', 'x', 'valid'];

  // TODO: keep the rows that are neither blank nor short.
  final kept = fx(rows).filter(isBlank.or(isShort).negate).toList();

  print(kept); // [fine, valid]
}
