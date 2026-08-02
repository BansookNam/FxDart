import 'package:rxdart/rxdart.dart';

// Fixed latency samples per endpoint, in ms.
const samples = {
  '/home': 62,
  '/login': 118,
  '/search': 87,
  '/cart': 45,
  '/checkout': 210,
  '/api/items': 74,
  '/api/user': 133,
  '/health': 12,
};

Future<int> measure(String path) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return samples[path]!;
}

Future<void> main() async {
  // min and max are each terminal, and a stream is single-subscription —
  // each reduction here consumes a fresh stream from the factory (one
  // asBroadcastStream pass could serve both — at the cost of tying the
  // two reductions to one subscription's lifetime).
  Stream<int> latencies() =>
      Stream.fromIterable(samples.keys).asyncMap(measure);

  final fastest = await latencies().min();
  final slowest = await latencies().max();

  print('fastest: $fastest ms');
  print('slowest: $slowest ms');
}
