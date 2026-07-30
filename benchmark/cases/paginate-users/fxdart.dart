import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final users = makeUsers();
  await bench(
    slug: 'paginate-users',
    impl: 'fxdart',
    n: n,
    run: () {
      final pages = fx(users)
          .chunk(10)
          .map((page) => '${page.length} users: ${page.join(', ')}')
          .toList();
      return '${pages.length}|${pages.first}|${pages.last}';
    },
  );
}
