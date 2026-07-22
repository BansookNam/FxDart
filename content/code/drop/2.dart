import 'package:fxdart/fxdart.dart';

void main() {
  final lines = ['# header', '# more header', 'data1', 'data2', 'data3'];

  // TODO: skip the first 2 header lines
  final data = fx(lines).toList();

  print(data);
}
