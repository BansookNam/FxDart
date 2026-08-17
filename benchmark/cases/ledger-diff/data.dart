// Deterministic before/after ledgers shared verbatim by both sides (headline
// 500k). after is before shifted by n/10: n/10 entries removed, n/10 added,
// the rest unchanged. Ids are zero-padded so lexicographic sort == numeric,
// and unique so the id sorts are tie-free. All fields derive from the id, so
// a common entry is identical in both ledgers. No Lcg needed — plain formulas.
//
// n is 500k, not the usual 1M: the diff is O(n) but hash-set heavy (three
// id sets plus uniq sets over ~2n string ids per iteration), and at 1M the
// fxdart side took 1.6-2.3s per iteration — not well under the 2s budget.

import '../../harness.dart';

final n = caseN(500000);
final _shift = n ~/ 10;

class Tx {
  final String id;
  final String desc;
  final double amount;
  const Tx(this.id, this.desc, this.amount);
}

const _descs = [
  'Rent',
  'Cafe Aroma',
  'Metro card',
  'Cinema',
  'Green Grocer',
  'Noodle Bar',
  'Pharmacy',
  'Book Nook',
];

Tx _tx(int i) => Tx(
  't${i.toString().padLeft(7, '0')}',
  _descs[i % _descs.length],
  (100 + (i * 37) % 9900) / 100,
);

List<Tx> makeBefore() => List.generate(n, (i) => _tx(i));
List<Tx> makeAfter() => List.generate(n, (i) => _tx(i + _shift));
