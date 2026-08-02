// Sync-shaped case (#33 all-validation-errors, async: false): n signup
// forms validated against three rules, every broken rule kept. Headline
// 1,000,000 (sync family scale) — the rx side drives each form through the
// stream event loop, but one iteration still fits well under 2 s.
import '../../harness.dart';

final n = caseN(1000000);

class Signup {
  const Signup(this.id, this.name, this.email, this.age);
  final int id;
  final String name;
  final String email;
  final int age;
}

List<String> ruleErrors(Signup s) => [
      if (s.name.isEmpty) 'name is required',
      if (!s.email.contains('@')) 'email is malformed',
      if (s.age < 18) 'must be 18 or older',
    ];

/// The scaled signup batch: each rule breaks on a deterministic slice of
/// forms (drawn from [Lcg.nextDouble] — high bits — per the harness note).
final forms = _makeForms();

List<Signup> _makeForms() {
  final rng = Lcg(33);
  return List.generate(n, (i) {
    final id = i + 1;
    final name = rng.nextDouble() < 0.15 ? '' : 'user$id';
    final email = rng.nextDouble() < 0.15
        ? 'user$id-example.com'
        : 'user$id@example.com';
    final age = rng.nextDouble() < 0.1 ? 15 : 18 + rng.nextInt(50);
    return Signup(id, name, email, age);
  });
}
