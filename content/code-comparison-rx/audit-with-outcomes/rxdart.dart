import 'package:rxdart/rxdart.dart';

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

Future<void> main() async {
  // An error normally terminates the stream, so keeping every failure
  // means one inner stream per line, its error smuggled back as data.
  final outcomes = await Stream.fromIterable(lines)
      .asyncExpand(
          (line) => Rx.fromCallable<(String, int)?>(() => parse(line))
              .onErrorReturn(null))
      .toList();

  for (final (key, value) in outcomes.whereType<(String, int)>()) {
    print('$key = $value');
  }
  print('failures: ${outcomes.where((o) => o == null).length}');
}
