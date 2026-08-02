import 'package:rxdart/rxdart.dart';

// Parsed amounts from a statement import — two lines failed to parse.
const List<int?> amounts = [12, 7, null, 40, 3, 88, null, 15, 62, 9];

Future<void> main() async {
  final total = await Stream.fromIterable(amounts)
      .whereNotNull()
      .where((a) => a.isEven)
      .fold<int>(0, (sum, a) => sum + a);

  print('Even total: $total');
}
