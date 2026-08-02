import 'package:fxdart/fxdart.dart';

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
  // The pipeline fetches 2 at a time in order, pairs the results with
  // chunk(2) — fxdart's bufferCount — and toStream() hands the batches to
  // any stream consumer; this one only prints.
  final batches = fx(orderIds)
      .toAsync()
      .mapConcurrent(2, fetchStatus)
      .chunk(2)
      .toStream();

  var i = 0;
  await for (final b in batches) {
    print('batch ${++i}: ${b.join(' | ')}');
  }
}
