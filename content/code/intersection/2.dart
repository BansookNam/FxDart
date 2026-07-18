import 'package:fxdart/fxdart.dart';

void main() {
  final requiredSkills = ['dart', 'sql'];
  final candidateSkills = ['dart', 'python', 'sql', 'sql'];

  // TODO: use intersection to find which of the candidate's skills are
  // actually required.
  final matched = toArray(candidateSkills);

  print(matched);
}
