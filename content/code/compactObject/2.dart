import 'package:fxdart/fxdart.dart';

void main() {
  final draft = {'title': 'hello', 'subtitle': null, 'body': 'world'};

  // TODO: use compactObject to drop null-valued keys
  final cleaned = draft;

  print(cleaned);
}
