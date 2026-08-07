import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // A suffix is only known once the source has ended, so the whole stream
  // is read before anything comes out.
  final tail = await fxAsync(toAsync([1, 4, 2, 3, 4]))
      .takeWhileRight((a) => a > 2)
      .toList();
  print(tail); // [3, 4]

  final settled = await fxStream(Stream.fromIterable([5, 9, 9]))
      .takeWhileRight((a) => a == 9)
      .toList();
  print(settled); // [9, 9]
}
