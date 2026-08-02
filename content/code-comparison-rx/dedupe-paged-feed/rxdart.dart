import 'package:rxdart/rxdart.dart';

// Three pages from a product feed — the page boundaries overlap.
const pages = [
  [(101, 'Desk lamp'), (102, 'Notebook'), (103, 'Pen set')],
  [(103, 'Pen set'), (104, 'Stapler'), (105, 'Monitor arm')],
  [(105, 'Monitor arm'), (106, 'Desk mat'), (101, 'Desk lamp')],
];

Future<void> main() async {
  final items = await Stream.fromIterable(pages)
      .expand((page) => page)
      // Plain Stream.distinct is adjacent-only; global dedup needs
      // distinctUnique with an equals/hashCode pair for the key.
      .distinctUnique(
          equals: (a, b) => a.$1 == b.$1, hashCode: (item) => item.$1)
      .map((item) => '#${item.$1} ${item.$2}')
      .toList();

  items.forEach(print);
}
