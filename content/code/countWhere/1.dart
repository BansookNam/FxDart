import 'package:fxdart/fxdart.dart';

Future<bool> isOverdue(String task) async {
  await Future.delayed(const Duration(milliseconds: 5));
  return task.startsWith('!');
}

void main() async {
  final tasks = ['!rent', 'call mom', '!invoice', 'water plants'];

  // The predicate may be async — awaited per element:
  final overdue = await fx(tasks).toAsync().countWhere(isOverdue);
  print('$overdue overdue'); // 2 overdue
}
