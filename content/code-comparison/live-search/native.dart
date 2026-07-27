/// A user typing toward "darts" — some keys repeat (autorepeat / jitter).
const typed = ['d', 'da', 'da', 'dar', 'dart', 'dart', 'darts', 'dart s'];

const titles = [
  'dart language tour', 'dart streams deep dive', 'darts scoring rules',
  'dart string interpolation', 'dartpad tips', 'flutter widgets',
];

int searches = 0;

/// The search backend: prefix match over titles.
Future<List<String>> fetchMatches(String q) async {
  searches++;
  await Future.delayed(const Duration(milliseconds: 10));
  return [for (final t in titles) if (t.startsWith(q)) t];
}

/// The keystroke source: a real Dart Stream, one key every 10 ms.
Stream<String> keystrokes() async* {
  for (final k in typed) {
    await Future.delayed(const Duration(milliseconds: 10));
    yield k;
  }
}

Future<void> main() async {
  final results = <(String, List<String>)>[];
  final seen = <String>{};
  await for (final q in keystrokes()) {
    if (q.length < 2 || !seen.add(q)) continue;
    results.add((q, await fetchMatches(q)));
    if (results.length == 4) break;
  }
  print('live search over the keystroke stream:');
  for (final (q, hits) in results) {
    print("  '$q' -> ${hits.length} hit${hits.length == 1 ? '' : 's'} "
        '(top: ${hits.first})');
  }
  print('backend searches: $searches');
}
