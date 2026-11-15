import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final menu = [
    (course: 'starter', choices: 3),
    (course: 'main', choices: 4),
    (course: 'dessert', choices: 2),
  ];

  // productBy multiplies a key — map + product in one step:
  print(fxProductBy((c) => c.choices, menu)); // 24
  print(fx(menu).productBy((c) => c.choices)); // 24

  // Async: the key may come back as a Future.
  Future<double> passRate(String stage) async =>
      stage == 'build' ? 0.5 : 0.75;
  final allPass = await fxAsync(fxToAsync(['build', 'test', 'deploy']))
      .productBy(passRate);
  print(allPass); // 0.28125
}
