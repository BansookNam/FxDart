import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

bool looksValid(String e) => e.contains('@') && e.contains('.');

Future<void> main() async {
  final rawEmails = makeRawEmails();
  await bench(
    slug: 'valid-emails',
    impl: 'fxdart',
    n: n,
    run: () {
      final emails = fx(rawEmails)
          .map((e) => e.trim().toLowerCase())
          .filter(looksValid)
          .take(takeLimit)
          .toList();
      return '${emails.length}|${emails.first}|${emails.last}';
    },
  );
}
