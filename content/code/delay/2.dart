import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // TODO: use delay to simulate a 100ms fetch that returns 'pong'
  final response = await delay(Duration(milliseconds: 100), 'pong');

  print(response); // pong
}
