import 'package:rxdart/rxdart.dart';

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
    impl: 'rxdart',
    n: n,
    run: () async {
      // min and max are each terminal, and a stream is single-subscription —
      // each reduction consumes a fresh stream from the factory, exactly as
      // in the example.
      Stream<int> latencies() =>
          Stream.fromIterable(samples.keys).asyncMap(measure);

      final fastest = await latencies().min();
      final slowest = await latencies().max();
      return 'fastest=$fastest|slowest=$slowest';
    },
  );
}
