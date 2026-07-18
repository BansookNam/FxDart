import 'package:fxdart/fxdart.dart';

void main() {
  final nested = {
    'id': 1,
    'address': {'city': 'seoul', 'zip': null},
    'nickname': null,
  };

  print(compactObject(nested));
  // {id: 1, address: {city: seoul, zip: null}} — nested null NOT removed
}
