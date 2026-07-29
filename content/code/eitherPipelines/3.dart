import 'package:fxdart/fxdart.dart';

Either<String, int> parse(String s) => either(
    (r) => r.ensureNotNull(int.tryParse(s), () => '"$s" is not a number'));

void main() {
  final raw = ['10', '20', 'x', '40'];
  final parsed = fx(raw).map(parse);

  // TODO: print the SUM of the successfully-parsed numbers (hint: sum()).
  print(parsed.rights()); // expect: 70

  // TODO: then report every failure.
  print(<String>[]); // expect: ["x" is not a number]
}
