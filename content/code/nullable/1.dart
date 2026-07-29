import 'package:fxdart/fxdart.dart';

const configs = {
  'prod': {'host': 'example.com', 'port': '443'},
  'dev': {'host': 'localhost', 'port': 'auto'},
};

// Every fallible hop is one r.bind — no `?.` staircases, no `??` towers,
// and unlike `?.` you can also assert conditions along the way.
int? port(String env) => nullable((r) {
  final cfg = r.ensureNotNull(configs[env]);
  final n = r.bind(int.tryParse(r.bind(cfg['port'])));
  r.ensure(n > 0);
  return n;
});

void main() {
  print(port('prod')); // 443
  print(port('dev')); // null — 'auto' is not a number
  print(port('staging')); // null — no such environment
}
