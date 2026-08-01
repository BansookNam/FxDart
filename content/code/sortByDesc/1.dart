import 'package:fxdart/fxdart.dart';

void main() {
  // Dates have no minus sign — sortBy((e) => -e.date) does not compile.
  final posts = [
    (title: 'hello world', date: DateTime(2026, 1, 5)),
    (title: 'typed errors', date: DateTime(2026, 7, 29)),
    (title: 'benchmarks', date: DateTime(2026, 7, 30)),
  ];

  final newestFirst = fx(posts).sortByDesc((p) => p.date).toList();
  print([for (final p in newestFirst) p.title]);
  // [benchmarks, typed errors, hello world]

  // Strings, either: reverse-alphabetical tags.
  print(sortByDesc((String t) => t, ['dart', 'fx', 'async']));
  // [fx, dart, async]
}
