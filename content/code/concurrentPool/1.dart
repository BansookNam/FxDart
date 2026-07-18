import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final delays = [300, 100, 200]; // item1 is slowest, item2 is fastest

  Future<FxAsync<String>> makeChain() async => fx([1, 2, 3])
      .toAsync()
      .map((i) => delay(Duration(milliseconds: delays[i - 1]), 'item$i'));

  // concurrent(3): still 3 in flight at once, but the *result* order always
  // matches the source order.
  final orderedIt = (await makeChain()).concurrent(3).iterator;
  final ordered =
      (await Future.wait([orderedIt.next(), orderedIt.next(), orderedIt.next()]))
          .map((r) => r.value)
          .toList();
  print(ordered); // [item1, item2, item3] — source order

  // concurrentPool(3): same 3-in-flight budget, but the *result* order
  // matches whichever finishes first.
  final poolIt = (await makeChain()).concurrentPool(3).iterator;
  final pooled =
      (await Future.wait([poolIt.next(), poolIt.next(), poolIt.next()]))
          .map((r) => r.value)
          .toList();
  print(pooled); // [item2, item3, item1] — completion order
}
