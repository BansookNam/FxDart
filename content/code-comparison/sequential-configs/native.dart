const configNames = ['features', 'limits', 'theme'];

const configValues = {
  'features': '{darkMode: true, beta: false}',
  'limits': '{maxUpload: 25, rateLimit: 120}',
  'theme': '{accent: teal, density: compact}',
};

Future<String> fetchConfig(String name) async {
  await Future.delayed(const Duration(milliseconds: 15)); // fake network
  return '$name -> ${configValues[name]}';
}

Future<void> main() async {
  // A plain loop awaits each fetch before starting the next.
  final loaded = <String>[];
  for (final name in configNames) {
    loaded.add(await fetchConfig(name));
  }
  print(loaded.join('\n'));
}
