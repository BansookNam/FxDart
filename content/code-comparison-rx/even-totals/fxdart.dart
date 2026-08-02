import 'package:fxdart/fxdart.dart';

// Parsed amounts from a statement import — two lines failed to parse.
const List<int?> amounts = [12, 7, null, 40, 3, 88, null, 15, 62, 9];

void main() {
  final total = fx(compact(amounts)).filter((a) => a.isEven).sum();

  print('Even total: $total');
}
