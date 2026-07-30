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

/// A hand-rolled worker pool: [limit] workers pull from a shared cursor,
/// writing into pre-sized slots so the output keeps the input order.
Future<List<String>> enrichAll(List<Merchant> picked, int limit) async {
  final results = List<String?>.filled(picked.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < picked.length) {
      final i = next++;
      final m = picked[i];
      final category = await lookupCategory(m.name);
      results[i] = '${m.name} — \$${m.total.toStringAsFixed(2)} ($category)';
    }
  }

  await Future.wait([for (var i = 0; i < limit; i++) worker()]);
  return results.cast<String>();
}

Future<void> main() async {
  await bench(
    slug: 'concurrent-enrichment',
    impl: 'native',
    n: n,
    run: () async {
      inFlight = 0;
      maxInFlight = 0;
      final top = [...merchants]..sort((a, b) => b.total.compareTo(a.total));
      final enriched = await enrichAll(top.take(enrichCount).toList(), 2);
      return '${enriched.length}|${enriched.first}|${enriched.last}|'
          'max=$maxInFlight';
    },
  );
}
