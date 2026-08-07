import 'package:fxdart/fxdart.dart';

void main() {
  final steps = ['trim', 'lower', 'slug'];

  // TODO: describe the pipeline as nested calls, outermost step first.
  final described = foldRight('input', (acc, String s) => '$s($acc)', steps);

  print(described); // trim(lower(slug(input)))
}
