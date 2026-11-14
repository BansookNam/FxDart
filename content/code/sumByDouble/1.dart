import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Empty input keeps its type: 0.0 and 0, not a bare num 0.
  print(sumByDouble((double x) => x, <double>[])); // 0.0
  print(sumByInt((String s) => s.length, <String>[])); // 0

  // Async: the selector may return a Future.
  Future<double> priceOf(String sku) async => sku.length * 1.5;
  final total = await fxAsync(fxToAsync(['ab', 'cde']))
      .sumByDouble(priceOf);
  print(total); // 7.5
}
