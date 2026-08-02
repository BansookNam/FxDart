import 'package:rxdart/rxdart.dart';

// Ten files waiting to go out — the API accepts at most four per request.
const pending = [
  'img-01', 'img-02', 'img-03', 'img-04', 'img-05', //
  'img-06', 'img-07', 'img-08', 'img-09', 'img-10',
];

Future<void> main() async {
  final requests = await Stream.fromIterable(pending)
      .bufferCount(4)
      .map((batch) => 'batch of ${batch.length}: ${batch.join(' ')}')
      .toList();

  requests.forEach(print);
}
