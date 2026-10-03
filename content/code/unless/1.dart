import 'package:fxdart/fxdart.dart';

void main() {
  final names = ['kim', '', 'lee', ''];
  final labeled = fx(names)
      .map((s) => fxUnless((s) => s.isNotEmpty, (_) => 'N/A', s))
      .toList();
  print(labeled); // [kim, N/A, lee, N/A]
}
