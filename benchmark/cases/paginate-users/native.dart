import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final users = makeUsers();
  await bench(
    slug: 'paginate-users',
    impl: 'native',
    n: n,
    run: () {
      // Core Dart has no chunking; package:collection's slices fills the gap.
      final pages = users
          .slices(10)
          .map((page) => '${page.length} users: ${page.join(', ')}')
          .toList();
      return '${pages.length}|${pages.first}|${pages.last}';
    },
  );
}
