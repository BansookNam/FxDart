import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

int inFlight = 0;
int maxInFlight = 0;

Future<String> lookupCategory(String name) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future<void>.delayed(Duration.zero);
  inFlight--;
  return directory[name]!;
}

Future<void> main() async {
  await bench(
    slug: 'concurrent-enrichment',
    impl: 'fxdart',
    n: n,
    run: () async {
      inFlight = 0;
      maxInFlight = 0;
      final enriched = await fx(merchants)
          .sortBy((m) => -m.total)
          .take(enrichCount)
          .toAsync()
          .map(
            (m) async =>
                '${m.name} — \$${m.total.toStringAsFixed(2)} '
                '(${await lookupCategory(m.name)})',
          )
          .concurrent(2)
          .toList();
      return '${enriched.length}|${enriched.first}|${enriched.last}|'
          'max=$maxInFlight';
    },
  );
}
