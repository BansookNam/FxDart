import 'package:rxdart/rxdart.dart';

const probeIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
const failing = {2, 5, 7, 8, 9};

int runs = 0;

// One health probe — throws when the endpoint is down.
Future<void> probe(int id) async {
  runs++;
  await Future.delayed(const Duration(milliseconds: 5));
  if (failing.contains(id)) throw StateError('probe $id failed');
}

Future<void> main() async {
  // Failures must become data before scan can count them — each probe
  // gets an inner stream that recovers the error as a marker value.
  final states = await Stream.fromIterable(probeIds)
      .asyncExpand((id) => Rx.fromCallable(() async {
            await probe(id);
            return true;
          }).onErrorReturn(false))
      .scan<({int done, int fails})>(
          (acc, ok, _) => (done: acc.done + 1, fails: acc.fails + (ok ? 0 : 1)),
          (done: 0, fails: 0))
      .takeWhileInclusive((s) => s.fails < 3)
      .toList();

  final last = states.last;
  print('processed: ${last.done}');
  print('failures: ${last.fails}');
  print('probes run: $runs');
}
