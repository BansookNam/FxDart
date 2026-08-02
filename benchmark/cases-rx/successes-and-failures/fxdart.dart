import 'package:fxdart/fxdart.dart';

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
    impl: 'fxdart',
    n: n,
    run: () async {
      // One try/catch turns each outcome into a plain value; partition
      // splits.
      final (ok, failed) =
          await fx(orders).toAsync().map<(int, Object?)>((id) async {
        try {
          return (await validate(id), null);
        } catch (e) {
          return (id, e);
        }
      }).partition((r) => r.$2 == null);

      return '${ok.length + failed.length}|ok=${ok.length}'
          '|failed=${failed.length}'
          '|${ok.first.$1}|${ok.last.$1}';
    },
  );
}
