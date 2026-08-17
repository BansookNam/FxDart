import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final posts = makePosts();
  await bench(
    slug: 'unique-tags',
    impl: 'fxdart',
    n: n,
    run: () {
      final tags = fx(
        posts,
      ).flatMap((p) => p.tags).uniq().sort((a, b) => a.compareTo(b)).toList();
      return '${tags.length}|${tags.first}|${tags.last}';
    },
  );
}
