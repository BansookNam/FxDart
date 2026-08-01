import 'package:fxdart/fxdart.dart';

Future<List<String>> search(String query) async {
  await Future.delayed(const Duration(milliseconds: 5));
  return ['$query-1', '$query-2'];
}

void main() async {
  final queries = ['dart', 'fx'];

  // TODO: pair each query with its results using attach —
  // the printout needs BOTH the query and what it found.
  final hits = await fx(queries)
      .toAsync()
      .map((q) async => (q, await search(q))) // ← replace with attach
      .toList();

  for (final (query, results) in hits) {
    print('$query → $results');
  }
  // dart → [dart-1, dart-2]
  // fx → [fx-1, fx-2]
}
