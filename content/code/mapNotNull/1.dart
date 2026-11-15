import 'package:fxdart/fxdart.dart';

/// A user service that only knows some ids.
Future<String?> lookupEmail(int id) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return {1: 'ana@x.io', 3: 'kim@x.io', 4: 'lee@x.io'}[id];
}

void main() async {
  final ids = [1, 2, 3, 4, 5];

  // Unknown ids drop out; three lookups run at a time.
  final emails = await fx(ids)
      .toAsync()
      .mapNotNull(lookupEmail)
      .concurrent(3)
      .toList();
  print(emails); // [ana@x.io, kim@x.io, lee@x.io]

  // The first id that resolves — no lookups after the hit.
  final first = await fx([5, 2, 3, 4]).toAsync().firstNotNullOf(lookupEmail);
  print(first); // kim@x.io
}
