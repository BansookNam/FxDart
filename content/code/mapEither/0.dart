import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Each event runs in its own raise scope: r.ensure / r.raise becomes
  // a Left, a normal return a Right. The source is not cancelled.
  final parsed = await fxEvents(Stream.fromIterable(['1', 'x', '3']))
      .mapEither<String, int>(
        (r, s) => r.ensureNotNull(int.tryParse(s), () => 'bad: $s'),
      )
      .toList();

  print(parsed);
  // [Right(1), Left(bad: x), Right(3)]
}
