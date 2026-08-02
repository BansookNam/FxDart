import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  await bench(
    slug: 'all-validation-errors',
    impl: 'fxdart',
    n: n,
    run: () {
      // Errors are plain values, so every broken rule survives to the
      // report.
      final (invalid, valid) = fx(forms)
          .map((s) => (form: s, errors: ruleErrors(s)))
          .partition((r) => r.errors.isNotEmpty);

      var errs = 0;
      for (final r in invalid) {
        errs += r.errors.length;
      }
      return '${invalid.length + valid.length}|invalid=${invalid.length}'
          '|valid=${valid.length}'
          '|errs=$errs|first=form #${invalid.first.form.id}';
    },
  );
}
