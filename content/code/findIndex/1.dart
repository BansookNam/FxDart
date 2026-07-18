import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  var checked = 0;
  final index = findIndex((a) {
    checked++;
    return a == 5;
  }, range(1000000));
  print(index);               // 5
  print('checked $checked');  // checked 6

  final asyncIndex = await fx(['x', 'y', 'z'])
      .toAsync()
      .findIndex((v) => delay(Duration(milliseconds: 30), v == 'z'));
  print(asyncIndex); // 2
}
