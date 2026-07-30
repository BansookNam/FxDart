// Deterministic 1,000,000-user cohort dataset shared verbatim by both sides.
// Cohort cardinality stays bounded (12 signup months); user count scales.
// Each user is active in their signup month and then retains month-over-month
// with a deterministically decaying probability.
import '../../harness.dart';

final n = caseN(1000000);

class User {
  final String name;
  final String signup; // signup month, 'yyyy-mm'
  final List<String> active; // months with at least one session
  const User(this.name, this.signup, this.active);
}

final List<String> months =
    List.generate(12, (i) => '2026-${(i + 1).toString().padLeft(2, '0')}');

List<User> makeUsers() {
  final rng = Lcg(4);
  return List.generate(n, (i) {
    // nextDouble-based draws: the LCG's low bits cycle, which would collapse
    // the cohorts to a few months; the high bits are well distributed.
    final s = (rng.nextDouble() * months.length).floor();
    final active = <String>[months[s]];
    for (var m = s + 1; m < months.length; m++) {
      // retention decays the further we get from signup
      final keepPct = 70 - 5 * (m - s);
      if (rng.nextDouble() * 100 < keepPct) active.add(months[m]);
    }
    return User('user$i', months[s], active);
  });
}
