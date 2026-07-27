import 'package:collection/collection.dart';

class Req {
  final String endpoint;
  final int ms;
  final int status;
  const Req(this.endpoint, this.ms, this.status);
}

const reqs = [
  Req('/users', 82, 200),
  Req('/users', 74, 200),
  Req('/users', 96, 200),
  Req('/users', 340, 200),
  Req('/users', 88, 200),
  Req('/orders', 120, 200),
  Req('/orders', 145, 200),
  Req('/orders', 110, 200),
  Req('/orders', 620, 200),
  Req('/orders', 133, 200),
  Req('/search', 210, 200),
  Req('/search', 480, 200),
  Req('/search', 190, 200),
  Req('/search', 205, 200),
  Req('/orders', 30, 500),
  Req('/users', 12, 503),
];

void main() {
  final ok = reqs.where((r) => r.status == 200).toList();

  final rows = <(String, int, int, int)>[];
  for (final e in ok.groupListsBy((r) => r.endpoint).entries) {
    final sorted = e.value.map((r) => r.ms).toList()..sort();
    int pct(int q) => sorted[((sorted.length - 1) * q / 100).round()];
    rows.add((e.key, pct(50), pct(95), sorted.length));
  }

  final lines = rows.sortedBy<num>((r) => -r.$3).map((r) =>
      '  ${r.$1.padRight(8)} p50 ${'${r.$2}'.padLeft(3)} ms  '
      'p95 ${'${r.$3}'.padLeft(3)} ms  (${r.$4} reqs)');
  final worst = rows.reduce((a, b) => a.$3 >= b.$3 ? a : b);

  print([
    'Latency percentiles (successful requests only)',
    ...lines,
    'Worst p95: ${worst.$1} at ${worst.$3} ms',
  ].join('\n'));
}
