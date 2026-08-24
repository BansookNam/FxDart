import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // mapEitherAsync is the async twin: one event at a time, like asyncMap.
  // A raise must happen inside the awaited chain — a raise from an
  // unawaited future outlives the scope and is not a Left.
  final out = await fxEvents(Stream.fromIterable([1, -2, 3]))
      .mapEitherAsync<String, int>((r, v) async {
        r.ensure(v > 0, () => 'negative: $v');
        return v * 2;
      })
      .toList();

  print(out);
  // [Right(2), Left(negative: -2), Right(6)]
}
