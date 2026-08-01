import 'package:fxdart/fxdart.dart';

void main() async {
  final words = ['ab', 'cd', 'e', 'fg', 'hij'];

  // The async twin is a terminal (like the async sortBy): the groups come
  // back as one Future<List> of the same named records.
  final groups =
      await fx(words).toAsync().map((w) => w.toUpperCase()).groupedBy(
            (w) => w.length,
          );

  for (final g in groups) {
    print('len ${g.key}: ${g.items}');
  }
  // len 2: [AB, CD, FG]
  // len 1: [E]
  // len 3: [HIJ]
}
