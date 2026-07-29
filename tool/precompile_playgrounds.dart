// Precompiles playground snippets into docs/pg/<id>.js.gz.
//
// A reader who has not edited the code should not have to wait ~2s for the
// DartPad compile service to rebuild the same snippet the site has shipped
// unchanged for months. This tool does that compile once, at build time;
// build_docs.dart then stamps the id on the `.playground` div and
// playground.js fetches the artifact instead of compiling.
//
// Output is gzipped because DDC emits the whole inlined library every time:
// ~700KB raw, ~64KB compressed. GitHub Pages serves .gz files as opaque bytes
// (no Content-Encoding), so playground.js decompresses them itself.
//
//   dart run tool/precompile_playgrounds.dart              build the default scope
//   dart run tool/precompile_playgrounds.dart --scope=all  every snippet on the site
//   dart run tool/precompile_playgrounds.dart --status     report coverage, no network
//   dart run tool/precompile_playgrounds.dart --prune      also drop stale artifacts
//
// Rerunnable and incremental: an artifact whose id already exists is left
// alone, so only new or changed snippets cost a round trip. Rebuilding
// docs/assets/fxdart_single.dart changes the id of every fxdart snippet, which
// is the point — a stale artifact can never outlive the library it was
// compiled against.

import 'dart:convert';
import 'dart:io';

import 'playground_source.dart';

const compileUrl = 'https://stable.api.dartpad.dev/api/v3/compileNewDDC';
const maxAttempts = 3;

final root = Directory.current.path;

void main(List<String> args) async {
  final scope = _flag(args, 'scope') ?? 'first';
  final concurrency = int.parse(_flag(args, 'concurrency') ?? '4');
  final prune = args.contains('--prune');
  final statusOnly = args.contains('--status');

  if (!File('$root/$libraryPath').existsSync()) {
    stderr.writeln('missing $libraryPath — run tools/build_single_file.sh first');
    exit(1);
  }
  if (scope != 'first' && scope != 'all' && scope != 'none') {
    stderr.writeln('unknown --scope=$scope (expected first, all, or none)');
    exit(1);
  }

  final all = snippets(root);
  final wanted = switch (scope) {
    'all' => all,
    'none' => <Snippet>[],
    _ => all.where((s) => s.isFirstOnPage).toList(),
  };

  // Deduplicate: two snippets with identical text share one artifact.
  final targets = <String, Snippet>{};
  for (final s in wanted) {
    targets.putIfAbsent(s.id, () => s);
  }

  Directory('$root/$artifactDir').createSync(recursive: true);
  var missing = targets.values
      .where((s) => !File(artifactPath(root, s.id)).existsSync())
      .toList();

  // Stop after N compiles. Useful for smoke-testing the pipeline without
  // spending a few hundred round trips on the compile service.
  final limit = int.tryParse(_flag(args, 'limit') ?? '');
  if (limit != null && limit < missing.length) {
    stdout.writeln('--limit=$limit: building $limit of ${missing.length} missing');
    missing = missing.take(limit).toList();
  }

  if (statusOnly) {
    _report(all, targets.keys.toSet(), missing.length, scope);
    return;
  }

  if (missing.isEmpty) {
    stdout.writeln('all ${targets.length} artifacts in scope "$scope" are current');
  } else {
    stdout.writeln('compiling ${missing.length} of ${targets.length} '
        'snippets in scope "$scope" ($concurrency at a time)…');
    final failures = await _compileAll(missing, concurrency);
    if (failures.isNotEmpty) {
      stderr.writeln('\n${failures.length} snippet(s) failed to compile:');
      for (final f in failures) {
        stderr.writeln('  ${f.key}\n    ${f.value.replaceAll('\n', '\n    ')}');
      }
      exit(1);
    }
  }

  if (prune) _prune(all);
  _report(all, targets.keys.toSet(), 0, scope);
}

String? _flag(List<String> args, String name) {
  for (final a in args) {
    if (a.startsWith('--$name=')) return a.substring(name.length + 3);
  }
  return null;
}

/// Runs `concurrency` compiles at a time. Returns (path, error) for each
/// snippet that could not be compiled.
Future<List<MapEntry<String, String>>> _compileAll(
    List<Snippet> targets, int concurrency) async {
  final lib = File('$root/$libraryPath').readAsStringSync();
  final queue = List.of(targets);
  final failures = <MapEntry<String, String>>[];
  var done = 0;

  Future<void> worker() async {
    while (queue.isNotEmpty) {
      final s = queue.removeAt(0);
      final source = needsLib(s.code) ? mergedSource(lib, s.code) : s.code;
      try {
        final js = await _compile(source);
        File(artifactPath(root, s.id))
            .writeAsBytesSync(gzip.encode(utf8.encode(js)));
      } on _CompileFailure catch (e) {
        failures.add(MapEntry(s.path, e.message));
      }
      done++;
      stdout.write('\r  $done/${targets.length}   ');
    }
  }

  await Future.wait(List.generate(concurrency, (_) => worker()));
  stdout.writeln();
  return failures;
}

/// One compile, retrying transport hiccups but not compile errors — a snippet
/// that does not compile is a broken demo and should stop the build.
Future<String> _compile(String source) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  try {
    for (var attempt = 1;; attempt++) {
      try {
        final req = await client.postUrl(Uri.parse(compileUrl));
        req.headers.contentType = ContentType.json;
        req.write(jsonEncode({'source': source}));
        final resp = await req.close();
        final text = await resp.transform(utf8.decoder).join();
        if (resp.statusCode == 200) return jsonDecode(text)['result'] as String;
        if (resp.statusCode == 400) {
          // The service reports genuine compile errors as 400.
          String message;
          try {
            message = jsonDecode(text)['error']?.toString() ?? text;
          } catch (_) {
            message = text;
          }
          throw _CompileFailure(message);
        }
        if (attempt >= maxAttempts) {
          throw _CompileFailure('HTTP ${resp.statusCode}: $text');
        }
      } on _CompileFailure {
        rethrow;
      } catch (e) {
        if (attempt >= maxAttempts) throw _CompileFailure('$e');
      }
      await Future<void>.delayed(Duration(seconds: attempt * 2));
    }
  } finally {
    client.close();
  }
}

class _CompileFailure implements Exception {
  _CompileFailure(this.message);
  final String message;
}

/// Deletes artifacts no current snippet maps to — typically everything
/// fxdart-flavoured after the single-file bundle is rebuilt.
void _prune(List<Snippet> all) {
  final live = {for (final s in all) s.id};
  var removed = 0, bytes = 0;
  for (final f in Directory('$root/$artifactDir').listSync().whereType<File>()) {
    final name = f.path.split(Platform.pathSeparator).last;
    if (!name.endsWith('.js.gz')) continue;
    if (live.contains(name.substring(0, name.length - 6))) continue;
    bytes += f.lengthSync();
    f.deleteSync();
    removed++;
  }
  if (removed > 0) {
    stdout.writeln('pruned $removed stale artifact(s), ${_mb(bytes)} freed');
  }
}

void _report(List<Snippet> all, Set<String> inScope, int missing, String scope) {
  final ids = {for (final s in all) s.id};
  var present = 0, bytes = 0;
  final dir = Directory('$root/$artifactDir');
  if (dir.existsSync()) {
    for (final f in dir.listSync().whereType<File>()) {
      final name = f.path.split(Platform.pathSeparator).last;
      if (!name.endsWith('.js.gz')) continue;
      if (!ids.contains(name.substring(0, name.length - 6))) continue;
      present++;
      bytes += f.lengthSync();
    }
  }
  stdout.writeln('scope "$scope": ${inScope.length} of ${ids.length} '
      'distinct snippets targeted');
  stdout.writeln('docs/pg: $present artifact(s), ${_mb(bytes)}'
      '${missing > 0 ? '  ($missing in scope not built yet)' : ''}');
}

String _mb(int bytes) => '${(bytes / 1048576).toStringAsFixed(1)}MB';
