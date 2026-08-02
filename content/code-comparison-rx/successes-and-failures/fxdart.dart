import 'package:fxdart/fxdart.dart';

// Orders from the 2026-08 import — two will fail validation.
const orders = [1001, 1002, 1003, 1004, 1005, 1006, 1007];

Future<int> validate(int id) async {
  await Future.delayed(const Duration(milliseconds: 10));
  if (id == 1003) throw StateError('missing shipping address');
  if (id == 1006) throw StateError('unknown SKU');
  return id;
}

Future<void> main() async {
  // One try/catch turns each outcome into a plain value; partition splits.
  final (ok, failed) = await fx(orders).toAsync().map<(int, Object?)>((id) async {
    try {
      return (await validate(id), null);
    } catch (e) {
      return (id, e);
    }
  }).partition((r) => r.$2 == null);

  for (final (id, _) in ok) {
    print('ok: order #$id');
  }
  print('failed: ${failed.length}');
}
