import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final visits = ['home', 'docs', 'home', 'home', 'docs'];

  final counts = await fx(visits)
      .toAsync()
      .countBy((page) => delay(const Duration(milliseconds: 100), page));

  print(counts); // {home: 3, docs: 2}
}
