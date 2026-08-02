import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final pages = makePages();
  await bench(
    slug: 'dedupe-paged-feed',
    impl: 'fxdart',
    n: n,
    run: () {
      final items = fx(pages)
          .flatMap((page) => page)
          .uniqBy((item) => item.$1)
          .map((item) => '#${item.$1} ${item.$2}')
          .toList();
      return '${items.length}|${items.first}|${items.last}';
    },
  );
}
