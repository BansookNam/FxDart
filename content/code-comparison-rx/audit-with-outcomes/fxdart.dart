import 'package:fxdart/fxdart.dart';

// Config lines from a deploy audit — three fail to parse.
const lines = [
  'timeout=30',
  'retries=four',
  'port=8080',
  'cache=',
  'workers=4',
  'depth=n/a',
  'ttl=300',
  'batch=25',
];

(String, int) parse(String line) {
  final parts = line.split('=');
  final value = int.tryParse(parts[1]);
  if (value == null) throw FormatException(line);
  return (parts[0], value);
}

(String, int)? tryParse(String line) {
  try {
    return parse(line);
  } on FormatException {
    return null;
  }
}

void main() {
  // The throw lands one try/catch away from being a plain value again,
  // and a single pass splits outcomes into the two lists the report needs.
  final (ok, failed) = fx(lines).map(tryParse).partition((r) => r != null);

  for (final (key, value) in ok.whereType<(String, int)>()) {
    print('$key = $value');
  }
  print('failures: ${failed.length}');
}
