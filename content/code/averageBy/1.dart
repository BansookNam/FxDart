import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // The async key extractor is awaited per element:
  final avg = await fx(['2', '4', '6'])
      .toAsync()
      .averageBy((s) => delay(const Duration(milliseconds: 100), int.parse(s)));

  print(avg); // 4.0
}
