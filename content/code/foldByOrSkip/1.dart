import 'package:fxdart/fxdart.dart';

void main() {
  final events = [
    (kind: 'click', page: '/pricing'),
    (kind: 'scroll', page: '/pricing'),
    (kind: 'click', page: '/docs'),
    (kind: 'click', page: '/pricing'),
  ];

  // The seed starts EVERY key — it does not run across them.
  print(foldByOrSkip(
    (e) => e.kind == 'click' ? e.page : null,
    100,
    (int n, e) => n + 1,
    events,
  ));
  // {/pricing: 102, /docs: 101}

  // A null key skips; it never becomes a bucket of its own.
  final none = foldByOrSkip((e) => null, 0, (int n, e) => n + 1, events);
  print(none.isEmpty);
  // true

  // The fold never sees a skipped element.
  var folded = 0;
  foldByOrSkip((e) => e.kind == 'click' ? e.page : null, 0, (int n, e) {
    folded++;
    return n + 1;
  }, events);
  print('folded $folded of ${events.length}');
  // folded 3 of 4
}
