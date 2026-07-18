import 'package:fxdart/fxdart.dart';

void main() {
  final completed = ['task1', 'task3'];
  final allTasks = ['task1', 'task2', 'task3', 'task4'];

  // TODO: use difference to find allTasks not yet in completed.
  final remaining = toArray(allTasks);

  print(remaining);
}
