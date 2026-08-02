import 'package:fxdart/fxdart.dart';

// Ten files waiting to go out — the API accepts at most four per request.
const pending = [
  'img-01', 'img-02', 'img-03', 'img-04', 'img-05', //
  'img-06', 'img-07', 'img-08', 'img-09', 'img-10',
];

void main() {
  final requests = fx(pending)
      .chunk(4)
      .map((batch) => 'batch of ${batch.length}: ${batch.join(' ')}')
      .toList();

  requests.forEach(print);
}
