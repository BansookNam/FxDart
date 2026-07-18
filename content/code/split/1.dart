import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await toArrayAsync(
    splitAsync(',', toAsync('x,y,z'.split(''))),
  );

  print(result); // [x, y, z]
}
