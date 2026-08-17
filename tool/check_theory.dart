// Runs every executable listing in the theory textbook.
//
//   dart run tool/check_theory.dart            all chapters
//   dart run tool/check_theory.dart 05 06      only these chapters
//
// The book asserts what programs print, so every ```dart run block must
// compile and run inside this package. Failures print the listing's chapter,
// index and the compiler's complaint; successes print the output so a writer
// can paste it back into the prose.
//
// Also enforces the 66-column rule on *every* fenced listing (runnable or
// not) — wider lines wrap inside the book's page box.
import 'dart:io';

const maxColumns = 66;

Future<void> main(List<String> args) async {
  final dir = Directory('${Directory.current.path}/content/theory');
  final files = dir
      .listSync()
      .whereType<File>()
      .map((f) => f.path)
      .where((p) => RegExp(r'/\d\d-[a-z0-9-]+\.md$').hasMatch(p))
      .where((p) => args.isEmpty || args.any((a) => p.contains('/$a-')))
      .toList()
    ..sort();

  final scratch = Directory('${Directory.current.path}/.theorycheck')
    ..createSync();
  var failures = 0, ran = 0, wide = 0;

  for (final path in files) {
    final name = path.split('/').last;
    final source = File(path).readAsStringSync();
    final blocks = RegExp(r'```([a-z ]*)\n(.*?)```', dotAll: true)
        .allMatches(source)
        .toList();

    for (var i = 0; i < blocks.length; i++) {
      final info = blocks[i].group(1)!.trim();
      final code = blocks[i].group(2)!;
      for (final line in code.split('\n')) {
        if (line.length > maxColumns) {
          wide++;
          stdout.writeln('WIDE  $name block ${i + 1}: ${line.length} cols'
              ' — ${line.trim()}');
        }
      }
      if (!info.split(RegExp(r'\s+')).contains('run')) continue;

      ran++;
      final file = File('${scratch.path}/${name.replaceAll('.md', '')}_$i.dart')
        ..writeAsStringSync(code);
      final result = await Process.run('dart', ['run', file.path]);
      if (result.exitCode != 0) {
        failures++;
        stdout.writeln('FAIL  $name block ${i + 1}');
        stdout.writeln(result.stderr.toString().trim().split('\n').take(8).join('\n'));
      } else {
        stdout.writeln('ok    $name block ${i + 1}');
        for (final line in result.stdout.toString().trimRight().split('\n')) {
          stdout.writeln('        $line');
        }
      }
    }
  }

  scratch.deleteSync(recursive: true);
  stdout.writeln('\n$ran listings run, $failures failed, '
      '$wide lines over $maxColumns columns');
  if (failures > 0 || wide > 0) exit(1);
}
