import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  var pulled = 0;
  final source = fx(range(1000000)).peek((_) => pulled++);
  final value = nth(3, source);
  print(value);             // 3
  print('pulled $pulled');  // pulled 4

  final asyncValue = await nthAsync(
      1, fx([10, 20, 30]).toAsync().map((a) => delay(Duration(milliseconds: 30), a)));
  print(asyncValue); // 20
}
