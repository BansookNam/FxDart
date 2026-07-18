import 'package:fxdart/fxdart.dart';

void main() {
  final List<String?> answers = ['yes', null, 'no', null, 'maybe'];

  // TODO: use compact to drop the nulls from answers.
  final cleaned = toArray(map((a) => a, answers));

  print(cleaned);
}
