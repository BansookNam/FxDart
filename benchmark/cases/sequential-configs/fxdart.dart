import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<String> fetchConfig(String name) async {
  await Future<void>.delayed(Duration.zero); // fake network
  return '$name -> ${configValues[name]}';
}

Future<void> main() async {
  await bench(
    slug: 'sequential-configs',
    impl: 'fxdart',
    n: n,
    run: () async {
      // Serial by default; adding .concurrent(n) later is a one-line change.
      final loaded = await fx(configNames).toAsync().map(fetchConfig).toList();
      return '${loaded.length}|${loaded.first}|${loaded.last}';
    },
  );
}
