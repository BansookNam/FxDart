import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  var checked = 0;
  final match = fx(range(1000000)).firstWhereOrNull((a) {
    checked++;
    return a == 5;
  });
  print(match);               // 5
  print('checked $checked');  // checked 6

  final firstOnline = await fx(['a', 'b', 'c'])
      .toAsync()
      .firstWhereOrNull((name) => delay(Duration(milliseconds: 30), name == 'b'));
  print(firstOnline); // b
}
