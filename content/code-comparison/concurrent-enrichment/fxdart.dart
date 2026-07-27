import 'package:fxdart/fxdart.dart';

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

Future<void> main() async {
  final enriched = await fx(merchants)
      .sortBy((m) => -m.total)
      .take(3)
      .toAsync()
      .map((m) async => '${m.name} — \$${m.total.toStringAsFixed(2)} '
          '(${await lookupCategory(m.name)})')
      .concurrent(2)
      .toList();
  print(enriched.join('\n'));
  print('max lookups in flight: $maxInFlight');
}
