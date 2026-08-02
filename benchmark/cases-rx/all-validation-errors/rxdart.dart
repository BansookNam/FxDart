import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  await bench(
    slug: 'all-validation-errors',
    impl: 'rxdart',
    n: n,
    run: () async {
      // The error channel carries ONE error and ends the stream — raising
      // the first broken rule would drop the rest, so accumulation has to
      // stay on the data channel by hand. The stream contributes nothing.
      final results = await Stream.fromIterable(forms)
          .map((s) => (form: s, errors: ruleErrors(s)))
          .toList();

      final invalid = results.where((r) => r.errors.isNotEmpty).toList();
      var errs = 0;
      for (final r in invalid) {
        errs += r.errors.length;
      }
      return '${results.length}|invalid=${invalid.length}'
          '|valid=${results.length - invalid.length}'
          '|errs=$errs|first=form #${invalid.first.form.id}';
    },
  );
}
