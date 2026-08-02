import 'package:rxdart/rxdart.dart';

// Orders from the 2026-08 import — two will fail validation.
const orders = [1001, 1002, 1003, 1004, 1005, 1006, 1007];

Future<int> validate(int id) async {
  await Future.delayed(const Duration(milliseconds: 10));
  if (id == 1003) throw StateError('missing shipping address');
  if (id == 1006) throw StateError('unknown SKU');
  return id;
}

Future<void> main() async {
  // A stream error ends the whole stream — each validation gets its own
  // inner stream so its failure can come back as data.
  final results = await Stream.fromIterable(orders)
      .asyncExpand((id) => Rx.fromCallable(() => validate(id))
          .map<(int, Object?)>((ok) => (ok, null))
          .onErrorReturnWith((e, _) => (id, e)))
      .toList();

  final ok = results.where((r) => r.$2 == null);
  for (final (id, _) in ok) {
    print('ok: order #$id');
  }
  print('failed: ${results.length - ok.length}');
}
