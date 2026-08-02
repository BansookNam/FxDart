// Verifies the Dart-vs-FxDart comparison examples (content/comparison/ +
// content/code-comparison/): for every example, both implementations must
// compile for the web, run on the VM, and print byte-identical output.
//
//   dart run tool/check_comparison.dart              verify all, write expected.txt
//   dart run tool/check_comparison.dart <slug> ...   verify only these examples
//   dart run tool/check_comparison.dart --check      fail if anything is stale (CI/deploy guard)
//   dart run tool/check_comparison.dart --rx [...]   same, for the RxDart-vs-FxDart
//                                                    family (content/comparison-rx/ +
//                                                    content/code-comparison-rx/; the
//                                                    left panel is rxdart.dart and may
//                                                    import only package:rxdart)
//
// What is enforced, per example directory content/code-comparison/<slug>/:
//   - native.dart and fxdart.dart exist and run to completion.
//   - Both print exactly the same stdout (the site shows it as verified
//     "Expected output"; nondeterministic prints are a bug in the example).
//   - expected.txt matches that output (written in default mode, a failure
//     in --check mode).
//   - No imports that cannot run in the browser playground (dart:io etc.).
//   - fxdart.dart imports package:fxdart; native.dart must not — the native
//     panel may import package:collection (DartPad supports it) but nothing
//     else outside dart:.
//
// The runner is fxdart's own concurrency pipeline — the examples are
// checked 8 at a time, in order. Dogfooding intended.

import 'dart:convert';
import 'dart:io';

import 'package:fxdart/fxdart.dart';

final root = Directory.current.path;

const _bannedImports = ['dart:io', 'dart:ffi', 'dart:isolate', 'dart:mirrors', 'dart:html'];

/// The two comparison families share one harness; `--rx` selects the second.
class _Family {
  const _Family({
    required this.contentDir,
    required this.codeDir,
    required this.leftFile,
    required this.leftAllowedPackages,
    required this.leftMustImport,
    required this.leftPolicy,
  });

  final String contentDir;
  final String codeDir;
  final String leftFile; // the non-fxdart panel
  final List<String> leftAllowedPackages;
  final String? leftMustImport; // package prefix the left panel must import
  final String leftPolicy; // human-readable import policy for error messages
}

const _dartFamily = _Family(
  contentDir: 'comparison',
  codeDir: 'code-comparison',
  leftFile: 'native.dart',
  leftAllowedPackages: ['package:collection/'],
  leftMustImport: null,
  leftPolicy: 'native panels may import only package:collection',
);

const _rxFamily = _Family(
  contentDir: 'comparison-rx',
  codeDir: 'code-comparison-rx',
  leftFile: 'rxdart.dart',
  leftAllowedPackages: ['package:rxdart/'],
  leftMustImport: 'package:rxdart/',
  leftPolicy: 'rxdart panels may import only package:rxdart',
);

late _Family _family;

class Failure {
  Failure(this.slug, this.message);
  final String slug;
  final String message;
  @override
  String toString() => '$slug: $message';
}

Future<void> main(List<String> args) async {
  final check = args.contains('--check');
  _family = args.contains('--rx') ? _rxFamily : _dartFamily;
  final only = args.where((a) => !a.startsWith('--')).toSet();

  final dir = Directory('$root/content/${_family.contentDir}');
  var slugs = dir
      .listSync()
      .whereType<File>()
      .map((f) => f.path.split('/').last)
      .where((n) => n.endsWith('.md'))
      .map((n) => n.substring(0, n.length - 3))
      .toList()
    ..sort();
  if (only.isNotEmpty) {
    final unknown = only.difference(slugs.toSet());
    if (unknown.isNotEmpty) {
      stderr.writeln('unknown example(s): ${unknown.join(', ')}');
      exit(2);
    }
    slugs = slugs.where(only.contains).toList();
  }

  final failures = <Failure>[];
  var written = 0;

  final results = await fx(slugs)
      .toAsync()
      .map((slug) => _verify(slug, check: check))
      .concurrent(8)
      .toList();

  for (final r in results) {
    failures.addAll(r.failures);
    if (r.wroteExpected) written++;
    stdout.writeln(r.line);
  }

  // The browser playground inlines docs/assets/fxdart_single.dart above each
  // fxdart panel. A top-level name that shadows a library export is legal on
  // the VM (separate libraries) but a redeclaration error in the merged file
  // — invisible to the run check above. Reproduce the exact merge locally and
  // analyze it.
  stdout.writeln('analyzing merged playground sources…');
  failures.addAll(_analyzeMerged(slugs));

  stdout.writeln('');
  stdout.writeln('${slugs.length} examples checked, '
      '${slugs.length - failures.map((f) => f.slug).toSet().length} passed'
      '${written > 0 ? ', $written expected.txt written' : ''}');
  if (failures.isNotEmpty) {
    stderr.writeln('');
    for (final f in failures) {
      stderr.writeln('FAIL $f');
    }
    exit(1);
  }
}

class _Result {
  _Result(this.line, this.failures, this.wroteExpected);
  final String line;
  final List<Failure> failures;
  final bool wroteExpected;
}

Future<_Result> _verify(String slug, {required bool check}) async {
  final failures = <Failure>[];
  final dir = '$root/content/${_family.codeDir}/$slug';
  final leftFile = File('$dir/${_family.leftFile}');
  final fxdartFile = File('$dir/fxdart.dart');

  for (final f in [leftFile, fxdartFile]) {
    if (!f.existsSync()) {
      failures.add(Failure(slug, 'missing ${f.path.split('/').last}'));
    }
  }
  if (failures.isNotEmpty) return _Result('✗ $slug', failures, false);

  _checkImports(slug, leftFile, isFxdart: false, failures: failures);
  _checkImports(slug, fxdartFile, isFxdart: true, failures: failures);

  final left = await _run(slug, leftFile, failures);
  final fxdartOut = await _run(slug, fxdartFile, failures);
  if (left == null || fxdartOut == null) {
    return _Result('✗ $slug', failures, false);
  }

  if (left != fxdartOut) {
    failures.add(Failure(
        slug,
        'output mismatch\n'
        '  ${_family.leftFile.split('.').first}: ${jsonEncode(left)}\n'
        '  fxdart: ${jsonEncode(fxdartOut)}'));
    return _Result('✗ $slug', failures, false);
  }

  final expectedFile = File('$dir/expected.txt');
  final current =
      expectedFile.existsSync() ? expectedFile.readAsStringSync() : null;
  var wrote = false;
  if (current != left) {
    if (check) {
      failures.add(Failure(
          slug,
          current == null
              ? 'expected.txt missing — run `dart run tool/check_comparison.dart`'
              : 'expected.txt is stale — run `dart run tool/check_comparison.dart`'));
    } else {
      expectedFile.writeAsStringSync(left);
      wrote = true;
    }
  }

  final ok = failures.isEmpty;
  return _Result('${ok ? '✓' : '✗'} $slug${wrote ? '  (expected.txt updated)' : ''}',
      failures, wrote);
}

void _checkImports(String slug, File file,
    {required bool isFxdart, required List<Failure> failures}) {
  final name = file.path.split('/').last;
  final source = file.readAsStringSync();
  final imports = RegExp(r'''^\s*import\s+['"]([^'"]+)['"]''', multiLine: true)
      .allMatches(source)
      .map((m) => m.group(1)!)
      .toList();

  for (final imp in imports) {
    if (_bannedImports.any(imp.startsWith)) {
      failures.add(Failure(slug, '$name imports $imp, which cannot run in the '
          'browser playground'));
    }
    if (imp.startsWith('package:')) {
      final allowed = isFxdart
          ? imp.startsWith('package:fxdart/')
          : _family.leftAllowedPackages.any(imp.startsWith);
      if (!allowed) {
        failures.add(Failure(slug, '$name imports $imp — not available in the '
            'playground (${isFxdart ? 'fxdart panels may import only package:fxdart' : _family.leftPolicy})'));
      }
    }
  }

  final importsFxdart = imports.any((i) => i.startsWith('package:fxdart/'));
  if (isFxdart && !importsFxdart) {
    failures.add(Failure(slug, '$name does not import package:fxdart'));
  }
  if (!isFxdart && importsFxdart) {
    failures.add(Failure(slug, '$name imports package:fxdart — the '
        '${_family.leftFile.split('.').first} panel must not use the library'));
  }
  final mustImport = _family.leftMustImport;
  if (!isFxdart &&
      mustImport != null &&
      !imports.any((i) => i.startsWith(mustImport))) {
    failures.add(Failure(slug, '$name does not import $mustImport — the '
        'left panel must actually use ${mustImport.substring(8).replaceAll('/', '')}'));
  }
}

/// Merges each fxdart panel with the single-file library exactly the way
/// docs/js/playground.js does (dart: imports hoisted, fxdart import commented
/// out, library prepended) and analyzes the results in one pass. Only
/// error-severity diagnostics fail — the inlined library itself trips lint
/// noise that is not the example's fault.
List<Failure> _analyzeMerged(List<String> slugs) {
  final lib = File('$root/docs/assets/fxdart_single.dart').readAsStringSync();
  final tmp = Directory.systemTemp.createTempSync('fxcmp_merged');
  try {
    for (final slug in slugs) {
      final user = File('$root/content/${_family.codeDir}/$slug/fxdart.dart')
          .readAsStringSync();
      final imports = <String>[];
      final body = <String>[];
      for (final line in user.split('\n')) {
        final t = line.trim();
        if (t.startsWith(RegExp(r'''import\s+['"]package:fxdart/'''))) {
          body.add('// $line');
        } else if (t.startsWith(RegExp(r'''import\s+['"]dart:'''))) {
          imports.add(line);
          body.add('// (hoisted) $line');
        } else {
          body.add(line);
        }
      }
      final merged = '${imports.join('\n')}${imports.isEmpty ? '' : '\n'}$lib'
          '\n// ===== user code below =====\n${body.join('\n')}';
      File('${tmp.path}/${slug.replaceAll('-', '_')}.dart')
          .writeAsStringSync(merged);
    }

    final result = Process.runSync('dart', ['analyze', tmp.path]);
    final failures = <Failure>[];
    for (final line in '${result.stdout}'.split('\n')) {
      final t = line.trim();
      if (!t.startsWith('error -')) continue;
      final slug = RegExp(r'([a-z0-9_]+)\.dart')
              .firstMatch(t)
              ?.group(1)
              ?.replaceAll('_', '-') ??
          '?';
      failures.add(Failure(slug, 'merged playground source: $t'));
    }
    return failures;
  } finally {
    tmp.deleteSync(recursive: true);
  }
}

/// Runs one implementation on the VM and returns its stdout, or null on
/// failure. Examples are in-memory programs with simulated delays, so 30s
/// means a hang, not a slow machine.
Future<String?> _run(String slug, File file, List<Failure> failures) async {
  final name = file.path.split('/').last;
  final proc = await Process.start('dart', ['run', file.path]);
  final out = proc.stdout.transform(utf8.decoder).join();
  final err = proc.stderr.transform(utf8.decoder).join();
  final code = await proc.exitCode.timeout(const Duration(seconds: 30),
      onTimeout: () {
    proc.kill(ProcessSignal.sigkill);
    return -1;
  });
  if (code != 0) {
    failures.add(Failure(slug,
        '$name ${code == -1 ? 'timed out after 30s' : 'exited with $code'}\n${await err}'));
    return null;
  }
  return await out;
}
