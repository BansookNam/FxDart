import 'package:fxdart/fxdart.dart';

void main() {
  final user = {'id': 1, 'name': 'kim'};
  print(prop('name', user));  // kim
  print(prop('email', user)); // null — same as user['email']
}
