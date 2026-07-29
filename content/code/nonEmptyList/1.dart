import 'package:fxdart/fxdart.dart';

void main() {
  final perms = Nel.of('read', ['write']);

  // map preserves non-emptiness in the type:
  final upper = perms.map((p) => p.toUpperCase());
  print(upper); // [READ, WRITE]

  // non-empty + non-empty is trivially non-empty:
  final all = Nel.of('admin') + upper;
  print(all); // [admin, READ, WRITE]

  // It IS an Iterable — every fxdart pipeline just works:
  print(fx(all).filter((p) => p != 'admin').toList()); // [READ, WRITE]

  // == is identity (extension type); use deepEquals for structure:
  print(upper == Nel.of('READ', ['WRITE'])); // false
  print(upper.deepEquals(Nel.of('READ', ['WRITE']))); // true
}
