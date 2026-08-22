// Rebuilds the playground artifacts for one built page, then restamps it.
//
// A local convenience, not a step anyone owes the repository: `docs/` is
// untracked and `.github/workflows/pages.yml` builds every artifact on a push
// to main. Use this when you have edited one page's snippets and want that
// page fast in a local preview without waiting for a full precompile.
//
// Editing a snippet changes its id, which orphans the artifact the page was
// stamped with — the panel silently falls back to the DartPad compile service
// and every reader pays ~2s on Run. Catching that means knowing which content
// files back a given URL, which is exactly the lookup this tool does.
//
//   dart run tool/rebuild_page.dart DartComparison/top-merchants.html
//   dart run tool/rebuild_page.dart tutorials/map.html tutorials/zip.html
//   dart run tool/rebuild_page.dart ko/DartComparison/top-merchants --dry-run
//
// The page may be given as a URL, a docs/ path, or a bare route, with or
// without `.html`. A locale prefix is accepted and ignored: playground code
// lives in content/code*/ and is never translated, so every locale of a page
// shares one artifact.
//
// Flags:
//   --dry-run      resolve and report; touch nothing
//
// This is a build tool, not a correctness gate: it will happily ship a snippet
// whose output drifted. Run `dart run tool/check_comparison.dart <slug>` for
// comparison pages, as before.

import 'dart:io';

import 'playground_source.dart';

final root = Directory.current.path;

void main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final pages = args.where((a) => !a.startsWith('--')).toList();

  if (pages.isEmpty) {
    stderr.writeln(
      'usage: dart run tool/rebuild_page.dart <page…> '
      '[--dry-run]\n'
      'e.g.  DartComparison/top-merchants.html',
    );
    exit(2);
  }

  // Resolve every page before doing any work, so a typo in the second argument
  // does not leave the first one half-rebuilt.
  final routes = <String, String>{}; // route -> content dir
  for (final page in pages) {
    final route = _route(page);
    final dir = _sourceDir(route);
    if (dir == null) {
      stderr.writeln(
        'no playgrounds known for "$route" (from "$page")\n'
        'expected one of: index, tutorials/<slug>, '
        'DartComparison/<slug>, RxDartComparison/<slug>',
      );
      exit(1);
    }
    if (!Directory('$root/$dir').existsSync()) {
      stderr.writeln('"$route" resolves to $dir, which does not exist');
      exit(1);
    }
    routes[route] = dir;
  }

  _warnIfBundleStale();

  final all = snippets(root);
  var missing = 0;
  for (final entry in routes.entries) {
    final found = all
        .where((s) => s.path.startsWith('${entry.value}/'))
        .toList();
    if (found.isEmpty) {
      stderr.writeln('${entry.key}: no snippets under ${entry.value}/');
      exit(1);
    }
    stdout.writeln(entry.key);
    for (final s in found) {
      final present = File(artifactPath(root, s.id)).existsSync();
      if (!present) missing++;
      stdout.writeln(
        '  ${present ? '✓' : '·'} ${s.path}  ${s.id}'
        '${present ? '' : '  (needs compile)'}',
      );
    }
  }
  stdout.writeln(
    missing == 0
        ? 'all artifacts current — rebuilding docs to confirm stamps'
        : '$missing snippet(s) to compile',
  );

  if (dryRun) return;

  // --prune drops whatever the edit orphaned; it only ever removes artifacts
  // no current snippet maps to, so a filtered run cannot delete another
  // page's work.
  await _run('dart', [
    'run',
    'tool/precompile_playgrounds.dart',
    '--only=${routes.values.map((d) => '$d/').join(',')}',
    '--prune',
  ]);
  await _run('dart', ['run', 'tool/build_docs.dart']);

  stdout.writeln(
    '\ndone — docs/ is untracked, so there is nothing to stage. '
    'Serve it with `./run.sh -s`.',
  );
}

/// Reduces any spelling of a page to `<family>/<slug>` (or `index`).
///
/// Everything to the left of the family is noise that differs per environment
/// — scheme and host, the `/FxDart/` base path a deployed URL carries, a local
/// `docs/` prefix, a locale directory — so the family is found by scanning
/// path suffixes rather than by stripping a fixed list of prefixes.
String _route(String raw) {
  var p = raw.trim().replaceAll('\\', '/');
  final uri = Uri.tryParse(p);
  if (uri != null && uri.hasScheme) p = uri.path;
  p = p.replaceAll(RegExp(r'^/+|/+$'), '');
  if (p.endsWith('.html')) p = p.substring(0, p.length - 5);
  if (p.isEmpty) return 'index';

  final parts = p.split('/');
  for (var i = parts.length - 2; i >= 0; i--) {
    if (_families.containsKey(parts[i]) && parts[i + 1].isNotEmpty) {
      return '${parts[i]}/${parts[i + 1]}';
    }
  }
  // The home page is the one route with no family segment, so it has to be
  // named outright — otherwise any unrecognised path would fall through to it.
  return parts.last == 'index' ? 'index' : p;
}

/// Route family -> content directory holding that family's playground sources.
/// Mirrors the walks in `snippets()`.
const _families = {
  'tutorials': 'content/code',
  'DartComparison': 'content/code-comparison',
  'RxDartComparison': 'content/code-comparison-rx',
};

/// The directory holding a route's playground sources, or null if that route
/// has no runnable code.
String? _sourceDir(String route) {
  if (route == 'index') return 'content/code/_index';
  final parts = route.split('/');
  if (parts.length != 2) return null;
  final base = _families[parts[0]];
  return base == null ? null : '$base/${parts[1]}';
}

/// Snippet ids are keyed on the bundle's hash, so compiling against a stale
/// bundle produces artifacts the next real build immediately orphans.
void _warnIfBundleStale() {
  final bundle = File('$root/$libraryPath');
  if (!bundle.existsSync()) return;
  final built = bundle.lastModifiedSync();
  final newer = Directory('$root/lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => f.lastModifiedSync().isAfter(built))
      .toList();
  if (newer.isNotEmpty) {
    stdout.writeln(
      'warning: lib/ has ${newer.length} file(s) newer than '
      '$libraryPath\n         run tools/build_single_file.sh first, or every '
      'fxdart id here is stale\n',
    );
  }
}

Future<void> _run(String exe, List<String> args) async {
  stdout.writeln('\n\$ $exe ${args.join(' ')}');
  final p = await Process.start(
    exe,
    args,
    workingDirectory: root,
    mode: ProcessStartMode.inheritStdio,
  );
  final code = await p.exitCode;
  if (code != 0) exit(code);
}
