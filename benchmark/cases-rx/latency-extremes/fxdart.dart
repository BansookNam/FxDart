import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<int> measure(String path) async {
  // Simulated probe latency — Duration.zero in the benchmark.
  await Future<void>.delayed(Duration.zero);
  return samples[path]!;
}

Future<void> main() async {
  await bench(
    slug: 'latency-extremes',
    impl: 'fxdart',
    n: n,
    run: () async {
      // min and max are each terminal — every reduction pulls the chain
      // afresh, exactly as in the example.
      FxAsync<int> latencies() => fx(samples.keys).toAsync().map(measure);

      final fastest = await latencies().min();
      final slowest = await latencies().max();
      return 'fastest=$fastest|slowest=$slowest';
    },
  );
}
