import '../../harness.dart';
import 'data.dart';

bool looksValid(String e) => e.contains('@') && e.contains('.');

Future<void> main() async {
  final rawEmails = makeRawEmails();
  await bench(
    slug: 'valid-emails',
    impl: 'native',
    n: n,
    run: () {
      final emails = rawEmails
          .map((e) => e.trim().toLowerCase())
          .where(looksValid)
          .take(takeLimit)
          .toList();
      return '${emails.length}|${emails.first}|${emails.last}';
    },
  );
}
