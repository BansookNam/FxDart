import 'package:fxdart/fxdart.dart';

void main() {
  final fail = throwError<String>((msg) => StateError(msg));

  try {
    fail('boom');
  } catch (e) {
    print('caught: $e'); // caught: Bad state: boom
  }
}
