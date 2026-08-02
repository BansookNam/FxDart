import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<int> validate(int id) async {
  await Future<void>.delayed(Duration.zero);
  if (id % 7 == 3) throw StateError('validation failed for #$id');
  return id;
}

Future<void> main() async {
  await bench(
    slug: 'successes-and-failures',
    impl: 'rxdart',
    n: n,
    run: () async {
      // A stream error ends the whole stream — each validation gets its
      // own inner stream so its failure can come back as data.
      final results = await Stream.fromIterable(orders)
          .asyncExpand((id) => Rx.fromCallable(() => validate(id))
              .map<(int, Object?)>((ok) => (ok, null))
              .onErrorReturnWith((e, _) => (id, e)))
          .toList();

      final ok = results.where((r) => r.$2 == null).toList();
      return '${results.length}|ok=${ok.length}'
          '|failed=${results.length - ok.length}'
          '|${ok.first.$1}|${ok.last.$1}';
    },
  );
}
