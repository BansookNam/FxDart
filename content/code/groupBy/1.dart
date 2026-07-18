import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final users = ['ann', 'al', 'bob', 'bea', 'cid'];

  // groupByAsync / .toAsync().groupBy(...) pulls the pipeline, awaiting the
  // key selector for each element.
  final byFirstLetter = await fx(users)
      .toAsync()
      .groupBy((u) => delay(const Duration(milliseconds: 100), u[0]));

  print(byFirstLetter); // {a: [ann, al], b: [bob, bea], c: [cid]}
}
