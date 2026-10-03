import 'package:fxdart/fxdart.dart';

void main() {
  final user = {'id': 1, 'name': 'kim'};
  print(fxProp('name', user));  // kim
  print(fxProp('email', user)); // null — same as user['email']
}
