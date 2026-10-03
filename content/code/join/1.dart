import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // joinAsync collects every value first, then joins them.
  final csv = await fxJoinAsync(
      ',',
      fxToAsync([
        fxDelay(const Duration(milliseconds: 100), 'a'),
        fxDelay(const Duration(milliseconds: 100), 'b'),
        fxDelay(const Duration(milliseconds: 100), 'c'),
      ]));
  print(csv); // a,b,c

  // FxAsync.join defaults its separator to ',' (not '' like the sync chain):
  final defaulted = await fx(['x', 'y', 'z']).toAsync().join();
  print(defaulted); // x,y,z
}
