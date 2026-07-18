import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final deck = [1, 2, 3, 4, 5];

  // shuffleAsync is the *Async twin — same seed gives the identical order
  // as the sync version, so a pipeline can switch between sync and async
  // sources without changing the reproducible result.
  final syncShuffled = shuffle(deck, 99);
  final asyncShuffled = await shuffleAsync(toAsync(deck), 99);
  print(syncShuffled); // [1, 3, 5, 4, 2]
  print(syncShuffled.toString() == asyncShuffled.toString()); // true

  // No elements are lost or duplicated — only reordered.
  print(List.of(syncShuffled)..sort()); // [1, 2, 3, 4, 5]
}
