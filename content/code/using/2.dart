import 'package:fxdart/fxdart.dart';

class Feed {
  var open = false;
  Iterable<int> ticks() => range(1, 100);
}

void main() {
  final feed = Feed();

  // TODO: this reads the feed but never manages its lifetime. Wrap it in
  // using(...) so `feed.open` is set on the first pull and cleared after
  // the last — and keep the .take(5): a BOUNDED pipeline completes, and
  // completion is what triggers release. (break-ing out of an unbounded
  // one would skip it — that is the documented pull-model caveat.)
  final firstFive = fx(feed.ticks()) // ← rebuild with using(...)
      .take(5)
      .toList();

  print(firstFive); // [1, 2, 3, 4, 5]
  print('open after iteration: ${feed.open}'); // must print false
}
