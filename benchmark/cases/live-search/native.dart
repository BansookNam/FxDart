import '../../harness.dart';
import 'data.dart';

int searches = 0;

/// The search backend: prefix match over titles.
Future<List<String>> fetchMatches(String q) async {
  searches++;
  await Future<void>.delayed(Duration.zero);
  return [
    for (final t in titles)
      if (t.startsWith(q)) t,
  ];
}

Future<void> main() async {
  final typed = makeTyped();
  await bench(
    slug: 'live-search',
    impl: 'native',
    n: n,
    run: () async {
      searches = 0;
      // A Stream can only be listened to once: create it fresh per run.
      final keystrokes = Stream<String>.fromIterable(typed);
      final results = <(String, List<String>)>[];
      final seen = <String>{};
      await for (final q in keystrokes) {
        if (q.length < 2 || !seen.add(q)) continue;
        results.add((q, await fetchMatches(q)));
        if (results.length == takeN) break;
      }
      final hits = results.fold(0, (sum, r) => sum + r.$2.length);
      return '${results.length}|searches=$searches|hits=$hits'
          '|first=${results.first.$1}|last=${results.last.$1}';
    },
  );
}
