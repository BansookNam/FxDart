// Deterministic 1,000,000-user roster shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

const _names = [
  'Ava',
  'Ben',
  'Cara',
  'Dan',
  'Elle',
  'Finn',
  'Gus',
  'Hana',
  'Ivan',
  'June',
  'Kai',
  'Lena',
];

List<String> makeUsers() {
  final rng = Lcg(8);
  return List.generate(n, (i) => '${_names[rng.nextInt(_names.length)]}-$i');
}
