import 'package:fxdart/fxdart.dart';

void main() {
  final answers = ['red', 'green', 'blue', 'yellow'];
  final isCorrect = [false, true, true, false];

  // TODO: use compress to keep only the correct answers.
  final correctAnswers = toList(answers);

  print(correctAnswers);
}
