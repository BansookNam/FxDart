import 'package:fxdart/fxdart.dart';

final products = [
  (name: 'oat milk', tags: ['vegan', 'drink']),
  (name: 'cheddar', tags: ['dairy']),
  (name: 'soy sauce', tags: ['vegan', 'pantry']),
];

Iterable<String> search(String tag) =>
    fx(products).filter((p) => p.tags.contains(tag)).map((p) => p.name);

void main() {
  // TODO: searching 'gluten-free' finds nothing. Fall back to the
  // 'vegan' search results instead of an empty list — with ifEmpty,
  // so the fallback search only runs when actually needed.
  final results = fx(search('gluten-free'))
      .toList(); // ← add .ifEmpty(...) before .toList()

  print(results);
  // Expected once solved: [oat milk, soy sauce]
}
