import 'package:fxdart/fxdart.dart';

class Signup {
  const Signup(this.id, this.name, this.email, this.age);
  final int id;
  final String name;
  final String email;
  final int age;
}

// The 2026-08 signup batch — three forms break at least one rule.
const forms = [
  Signup(1, 'ana', 'ana@example.com', 29),
  Signup(2, '', 'bo.example.com', 17),
  Signup(3, 'cy', 'cy@example.com', 41),
  Signup(4, 'dee', 'dee-example.com', 35),
  Signup(5, '', 'eli@example.com', 15),
];

List<String> ruleErrors(Signup s) => [
      if (s.name.isEmpty) 'name is required',
      if (!s.email.contains('@')) 'email is malformed',
      if (s.age < 18) 'must be 18 or older',
    ];

void main() {
  // Errors are plain values, so every broken rule survives to the report.
  final (invalid, valid) = fx(forms)
      .map((s) => (form: s, errors: ruleErrors(s)))
      .partition((r) => r.errors.isNotEmpty);

  for (final r in invalid) {
    print('form #${r.form.id}: ${r.errors.join('; ')}');
  }
  print('valid: ${valid.map((r) => r.form.name).join(', ')}');
}
