import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final pending = makePending();
  await bench(
    slug: 'upload-batches',
    impl: 'rxdart',
    n: n,
    run: () async {
      final requests = await Stream.fromIterable(pending)
          .bufferCount(4)
          .map((batch) => 'batch of ${batch.length}: ${batch.join(' ')}')
          .toList();
      return '${requests.length}|${requests.first}|${requests.last}';
    },
  );
}
