import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final pages = makePages();
  await bench(
    slug: 'dedupe-paged-feed',
    impl: 'rxdart',
    n: n,
    run: () async {
      final items = await Stream.fromIterable(pages)
          .expand((page) => page)
          // Plain Stream.distinct is adjacent-only; global dedup needs
          // distinctUnique with an equals/hashCode pair for the key.
          .distinctUnique(
            equals: (a, b) => a.$1 == b.$1,
            hashCode: (item) => item.$1,
          )
          .map((item) => '#${item.$1} ${item.$2}')
          .toList();
      return '${items.length}|${items.first}|${items.last}';
    },
  );
}
