import 'package:fxdart/fxdart.dart';

void main() {
  var loggedCount = 0;

  // TODO: consume only the first 3 values of an infinite repeat(), logging
  // each one as it is pulled.
  fx(repeat(1000000, 'ping'))
      .peek((_) => loggedCount++)
      .consume(3);

  print(loggedCount); // 3
}
