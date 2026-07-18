import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // indexByAsync / .toAsync().indexBy(...) still keeps only the last value
  // seen for each key, in pipeline order.
  final latestByUser = await fx(['ann:1', 'bob:2', 'ann:3'])
      .toAsync()
      .map((s) => delay(const Duration(milliseconds: 100), s))
      .indexBy((s) => s.split(':')[0]);

  print(latestByUser); // {ann: ann:3, bob: bob:2}
}
