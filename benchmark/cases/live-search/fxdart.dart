import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

int searches = 0;

/// The search backend: prefix match over titles.
Future<List<String>> fetchMatches(String q) async {
  searches++;
  await Future<void>.delayed(Duration.zero);
  return [for (final t in titles) if (t.startsWith(q)) t];
}

Future<void> main() async {
  final typed = makeTyped();
  await bench(
    slug: 'live-search',
    impl: 'fxdart',
    n: n,
    run: () async {
      searches = 0;
      // A Stream can only be listened to once: create it fresh per run.
      final results = await fxStream(Stream<String>.fromIterable(typed))
          .filter((q) => q.length >= 2)
          .uniq()
          .take(takeN)
          .map((q) async => (q, await fetchMatches(q)))
          .toList();
      final hits = fx(results).sumBy((r) => r.$2.length);
      return '${results.length}|searches=$searches|hits=$hits'
          '|first=${results.first.$1}|last=${results.last.$1}';
    },
  );
}
