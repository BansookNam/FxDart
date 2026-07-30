import '../../harness.dart';
import 'data.dart';

Future<String> fetchConfig(String name) async {
  await Future<void>.delayed(Duration.zero); // fake network
  return '$name -> ${configValues[name]}';
}

Future<void> main() async {
  await bench(
    slug: 'sequential-configs',
    impl: 'native',
    n: n,
    run: () async {
      // A plain loop awaits each fetch before starting the next.
      final loaded = <String>[];
      for (final name in configNames) {
        loaded.add(await fetchConfig(name));
      }
      return '${loaded.length}|${loaded.first}|${loaded.last}';
    },
  );
}
