import 'package:fxdart/fxdart.dart';

void main() {
  final user = {
    'id': 1,
    'name': 'kim',
    'address': {'city': 'seoul', 'zip': '100'}
  };

  print(fxIsMatch(user, {'name': 'kim'})); // true — extra keys ignored
  print(fxIsMatch(user, {
    'address': {'city': 'seoul'}
  })); // true — nested partial match
  print(fxIsMatch(user, {'name': 'lee'})); // false
}
