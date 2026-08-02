import 'package:rxdart/rxdart.dart';

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

Future<void> main() async {
  // The error channel carries ONE error and ends the stream — raising the
  // first broken rule would drop the rest, so accumulation has to stay on
  // the data channel by hand. The stream contributes nothing here.
  final results = await Stream.fromIterable(forms)
      .map((s) => (form: s, errors: ruleErrors(s)))
      .toList();

  for (final r in results.where((r) => r.errors.isNotEmpty)) {
    print('form #${r.form.id}: ${r.errors.join('; ')}');
  }
  final valid = results.where((r) => r.errors.isEmpty);
  print('valid: ${valid.map((r) => r.form.name).join(', ')}');
}
