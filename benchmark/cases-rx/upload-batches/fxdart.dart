import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final pending = makePending();
  await bench(
    slug: 'upload-batches',
    impl: 'fxdart',
    n: n,
    run: () {
      final requests = fx(pending)
          .chunk(4)
          .map((batch) => 'batch of ${batch.length}: ${batch.join(' ')}')
          .toList();
      return '${requests.length}|${requests.first}|${requests.last}';
    },
  );
}
