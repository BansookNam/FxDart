// Deterministic n-product catalog shared verbatim by both sides.
// Prices are a bijective permutation of [1.00, (100 + n - 1)/100] so every
// price is unique — native's unstable List.sort and fxdart's sortBy would
// otherwise order tied prices differently and the page contents would
// diverge. Bijectivity: 999983 is prime and > 10^6, so it is coprime with
// every runner scale (100, 10,000, 1,000,000) and i -> (i * 999983) % n
// permutes [0, n).
import '../../harness.dart';

final n = caseN(1000000);
const page = 2;
const pageSize = 3;

class Product {
  final String name;
  final double price;
  final bool inStock;
  const Product(this.name, this.price, this.inStock);
}

const _names = [
  'Espresso Kit',
  'Travel Mug',
  'Pour-over Set',
  'Grinder',
  'Filter Pack',
  'Milk Frother',
  'Scale',
  'Kettle',
  'Tamper',
  'Cold Brew Jar',
];

List<Product> makeProducts() {
  final rng = Lcg(4);
  return List.generate(n, (i) {
    final perm = (i * 999983) % n; // coprime with n at every scale: bijection
    return Product(
      '${_names[rng.nextInt(_names.length)]} #$i',
      (100 + perm) / 100,
      rng.nextInt(10) != 0, // 90% in stock
    );
  });
}
