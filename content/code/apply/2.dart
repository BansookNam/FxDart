import 'package:fxdart/fxdart.dart';

String greet(String name, String greeting) => '$greeting, $name!';

void main() {
  // TODO: call greet with these args using apply
  final message = apply<String>(greet, ['Kim', 'Hello']);

  print(message); // Hello, Kim!
}
