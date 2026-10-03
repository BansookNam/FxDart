import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await fxToListAsync(
    fxSplitAsync(',', fxToAsync('x,y,z'.split(''))),
  );

  print(result); // [x, y, z]
}
