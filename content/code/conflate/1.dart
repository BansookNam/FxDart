import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sync = fxConflate<int>(
    (version) async {
      await fxSleep(const Duration(milliseconds: 20));
      if (version == 1) throw StateError('offline');
      print('synced v$version');
    },
    onError: (e, _) => print('failed: $e'),
  );

  sync(1);
  print('running: ${sync.isRunning}'); // running: true
  sync(2);
  sync(3);
  print('pending: ${sync.isPending}'); // pending: true
  await sync.idle;
  // failed: Bad state: offline
  // synced v3   (an error does not stop the next run)
}
