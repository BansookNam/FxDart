import 'package:fxdart/fxdart.dart';

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
  final ok = fx(reqs).filter((r) => r.status == 200).toList();

  final rows = fx(fx(ok).groupBy((r) => r.endpoint).entries).map((e) {
    final sorted = fx(e.value).map((r) => r.ms).sortBy((ms) => ms).toList();
    int pct(int q) => nth(((sorted.length - 1) * q / 100).round(), sorted)!;
    return (e.key, pct(50), pct(95), sorted.length);
  }).toList();

  final lines = fx(rows).sortBy((r) => -r.$3).map((r) =>
      '  ${r.$1.padRight(8)} p50 ${'${r.$2}'.padLeft(3)} ms  '
      'p95 ${'${r.$3}'.padLeft(3)} ms  (${r.$4} reqs)');
  final worst = fx(rows).maxBy((r) => r.$3)!;

  print(join('\n', [
    'Latency percentiles (successful requests only)',
    ...lines,
    'Worst p95: ${worst.$1} at ${worst.$3} ms',
  ]));
}
