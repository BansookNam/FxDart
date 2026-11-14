import 'package:fxdart/fxdart.dart';

void main() {
  final fish = [
    (name: 'neon', tier: 'b'),
    (name: 'oscar', tier: 'a'),
    (name: 'guppy', tier: 'b'),
    (name: 'angel', tier: 'a'),
  ];

  // Stable: equal keys keep their input order, on every key type.
  // So sort by the secondary key first, then by the primary one:
  final byName = fx(fish).sortBy((f) => f.name);
  final ordered = byName.sortBy((f) => f.tier).toList();
  for (final f in ordered) {
    print('${f.tier} ${f.name}');
  }
  // a angel
  // a oscar
  // b guppy
  // b neon
}
