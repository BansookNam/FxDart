import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final source = <Either<String, int>>[
    const Right(1),
    const Left('a'),
    const Right(2),
    const Left('b'),
  ];

  print(await fxEvents(Stream.fromIterable(source)).rights().toList());
  // [1, 2]
  print(await fxEvents(Stream.fromIterable(source)).lefts().toList());
  // [a, b]
}
