import 'package:fxdart/fxdart.dart';

void main() {
  final profile = {'id': 7, 'email': 'a@b.com', 'passwordHash': 'xyz'};

  // TODO: use pick to keep only 'id' and 'email'
  final publicProfile = profile;

  print(publicProfile);
}
