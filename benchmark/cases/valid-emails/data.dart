// Deterministic n-entry raw signup list shared verbatim by both sides.
// ~80% of entries are valid emails; the rest miss the '@' or the '.'.
import '../../harness.dart';

final n = caseN(1000000);

// The example's take(5) scaled up: a cap of 5 would let the lazy pipeline
// stop after a handful of elements and measure nothing. n ~/ 2 keeps the
// take meaningful at every scale (at the 80% valid rate it truncates after
// ~5/8 of the inputs).
final takeLimit = n ~/ 2;

const _users = [
  'ada', 'grace', 'lin', 'ken', 'dennis',
  'barbara', 'alan', 'edsger', 'john', 'tony',
];
const _domains = [
  'example.com', 'hopper.dev', 'lang.org',
  'unix.org', 'types.edu', 'mail.net',
];
const _badDomains = ['nodot', 'missingtld']; // has '@' but no '.'

List<String> makeRawEmails() {
  final rng = Lcg(2);
  return List.generate(n, (i) {
    final user = _users[rng.nextInt(_users.length)];
    final kind = rng.nextInt(10);
    var email = switch (kind) {
      0 => 'not-an-email-$i', // no '@', no '.'
      1 => '$user$i@${_badDomains[rng.nextInt(_badDomains.length)]}',
      _ => '$user$i@${_domains[rng.nextInt(_domains.length)]}',
    };
    if (rng.nextInt(2) == 0) email = email.toUpperCase();
    return '${' ' * rng.nextInt(3)}$email${' ' * rng.nextInt(3)}';
  });
}
