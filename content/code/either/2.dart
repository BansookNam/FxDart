import 'package:fxdart/fxdart.dart';

int riskyParse(String raw) => int.parse(raw); // throws FormatException

void main() {
  print(Either.catching(() => riskyParse('42'))); // Right(42)

  // TODO: riskyParse('oops') throws. Capture it with
  //   Either.catchingWith((e, st) => 'bad input', () => riskyParse('oops'))
  // so this prints Left(bad input) instead of crashing.
  final Either<String, int> result = Right(riskyParse('42'));
  print(result);
}
