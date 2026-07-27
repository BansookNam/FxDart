class Merchant {
  final String name;
  final double total;
  const Merchant(this.name, this.total);
}

// Per-merchant spend totals for July 2026.
const merchants = [
  Merchant('Green Grocer', 118.65),
  Merchant('Cafe Aroma', 34.80),
  Merchant('Electric Co', 60.34),
  Merchant('Noodle Bar', 54.70),
  Merchant('Metro', 21.50),
  Merchant('Cinema', 15.00),
  Merchant('StreamFlix', 9.99),
  Merchant('Taxi', 24.00),
];

const directory = {
  'Green Grocer': 'Groceries',
  'Electric Co': 'Utilities',
  'Noodle Bar': 'Dining',
  'Cafe Aroma': 'Dining',
};

int inFlight = 0;
int maxInFlight = 0;

Future<String> lookupCategory(String name) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future.delayed(const Duration(milliseconds: 15));
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
  final top = [...merchants]..sort((a, b) => b.total.compareTo(a.total));
  final enriched = await enrichAll(top.take(3).toList(), 2);
  print(enriched.join('\n'));
  print('max lookups in flight: $maxInFlight');
}
