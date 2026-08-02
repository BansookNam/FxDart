import 'package:fxdart/fxdart.dart';

// Three pages from a product feed — the page boundaries overlap.
const pages = [
  [(101, 'Desk lamp'), (102, 'Notebook'), (103, 'Pen set')],
  [(103, 'Pen set'), (104, 'Stapler'), (105, 'Monitor arm')],
  [(105, 'Monitor arm'), (106, 'Desk mat'), (101, 'Desk lamp')],
];

void main() {
  fx(pages)
      .flatMap((page) => page)
      .uniqBy((item) => item.$1)
      .map((item) => '#${item.$1} ${item.$2}')
      .toList()
      .forEach(print);
}
