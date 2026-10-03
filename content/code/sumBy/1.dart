import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // The async key extractor is awaited per element:
  final total = await fx(['4', '20', '18'])
      .toAsync()
      .sumBy((s) => fxDelay(const Duration(milliseconds: 100), int.parse(s)));

  print(total); // 42
}
