import 'package:rxdart/rxdart.dart';

const orderIds = ['A-101', 'A-102', 'A-103', 'A-104', 'A-105'];
const statuses = {
  'A-101': 'shipped',
  'A-102': 'packed',
  'A-103': 'allocated',
  'A-104': 'delayed',
  'A-105': 'shipped',
};
const delaysMs = {
  'A-101': 60,
  'A-102': 150,
  'A-103': 180,
  'A-104': 200,
  'A-105': 210,
};

Future<String> fetchStatus(String id) async {
  await Future.delayed(Duration(milliseconds: delaysMs[id]!));
  return '$id ${statuses[id]}';
}

Future<void> main() async {
  // Streams end to end: bounded concurrent fetch, then buffer into pairs.
  final batches = await Stream.fromIterable(orderIds)
      .flatMap((id) => Stream.fromFuture(fetchStatus(id)), maxConcurrent: 2)
      .bufferCount(2)
      .toList();

  for (final (i, batch) in batches.indexed) {
    print('batch ${i + 1}: ${batch.join(' | ')}');
  }
}
