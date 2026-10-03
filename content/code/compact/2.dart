import 'package:fxdart/fxdart.dart';

void main() {
  final List<String?> answers = ['yes', null, 'no', null, 'maybe'];

  // TODO: use nonNulls to drop the nulls from answers.
  final cleaned = fxToList(fxMap((a) => a, answers));

  print(cleaned);
}
