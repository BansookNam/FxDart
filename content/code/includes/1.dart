import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  var checked = 0;
  final found = await includesAsync(
      2, fx([1, 2, 3, 4, 5]).toAsync().peek((_) => checked++));
  print(found);               // true
  print('checked $checked');  // checked 2 — stops once found
}
