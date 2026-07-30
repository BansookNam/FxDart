import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final posts = makePosts();
  await bench(
    slug: 'unique-tags',
    impl: 'native',
    n: n,
    run: () {
      final tags = posts.expand((p) => p.tags).toSet().toList()..sort();
      return '${tags.length}|${tags.first}|${tags.last}';
    },
  );
}
