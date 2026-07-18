import 'package:fxdart/fxdart.dart';

void main() {
  final lines = ['data1', 'data2', 'data3', '# footer', '# more footer'];

  // TODO: drop the last 2 footer lines
  final data = fx(lines).toArray();

  print(data);
}
