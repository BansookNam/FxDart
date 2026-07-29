import 'package:fxdart/fxdart.dart';

const Map<String, int?> lastSeen = {'kim': 1721900000, 'lee': null};

String? describe(String name) => nullable((r) {
  // TODO: use r.bind so a missing user AND a null timestamp both make
  // the whole block return null (right now 'lee' prints a lie).
  final ts = lastSeen[name];
  return '$name was last seen at $ts';
});

void main() {
  print(describe('kim')); // expect: kim was last seen at 1721900000
  print(describe('lee')); // expect: null
  print(describe('park')); // expect: null
}
