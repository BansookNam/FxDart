import 'package:fxdart/fxdart.dart';

String summarize(List<String> errors) {
  final nel = NonEmptyList.orNull(errors);
  if (nel == null) return 'ok';
  // TODO: report '<length> error(s), first: <head>'
  // using nel.length and nel.head — both total, neither can throw.
  return 'some errors';
}

void main() {
  print(summarize([])); // expect: ok
  print(summarize(['name is empty', 'age is negative']));
  // expect: 2 error(s), first: name is empty
}
