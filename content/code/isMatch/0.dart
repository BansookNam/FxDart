import 'package:fxdart/fxdart.dart';

void main() {
  final user = {
    'id': 1,
    'name': 'kim',
    'address': {'city': 'seoul', 'zip': '100'}
  };

  print(isMatch(user, {'name': 'kim'})); // true — extra keys ignored
  print(isMatch(user, {
    'address': {'city': 'seoul'}
  })); // true — nested partial match
  print(isMatch(user, {'name': 'lee'})); // false
}
