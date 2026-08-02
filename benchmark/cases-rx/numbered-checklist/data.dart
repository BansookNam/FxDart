// Deterministic n-step setup checklist shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

const _verbs = [
  'Unbox', 'Charge', 'Pair', 'Mount', 'Run', //
  'Register', 'Calibrate', 'Inspect', 'Label', 'Stow',
];
const _nouns = [
  'sensor kit', 'base station', 'remote', 'wall bracket', 'self-test', //
  'warranty', 'gateway', 'antenna', 'battery pack', 'mounting plate',
];

List<String> makeSteps() {
  final rng = Lcg(8);
  return List.generate(
    n,
    (i) => '${_verbs[rng.nextInt(_verbs.length)]} '
        'the ${_nouns[rng.nextInt(_nouns.length)]}',
  );
}
