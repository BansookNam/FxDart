import 'package:fxdart/fxdart.dart';

// Raw signup input: stray whitespace, mixed case, a few invalid entries.
const rawEmails = [
  '  Ada@Example.com ',
  'grace@hopper.dev',
  'not-an-email',
  'LIN@lang.org  ',
  'ken@unix.org',
  'broken@nodot',
  '  dennis@unix.org',
  'barbara@types.edu',
];

bool looksValid(String e) => e.contains('@') && e.contains('.');

void main() {
  final emails = fx(rawEmails)
      .map((e) => e.trim().toLowerCase())
      .filter(looksValid)
      .take(5);
  for (final e in emails) {
    print(e);
  }
}
