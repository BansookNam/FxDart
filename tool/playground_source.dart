// Shared between tool/build_docs.dart and tool/precompile_playgrounds.dart.
//
// The playground can run a snippet three ways, cheapest first: a build-time
// artifact under docs/pg/, a compile cached in the reader's browser, or a
// round trip to the DartPad compile service. This file owns everything the
// first path needs on the Dart side:
//
//   * `mergedSource` — the exact library+snippet merge docs/js/playground.js
//     performs, so what we precompile is what the reader would have compiled.
//   * `playgroundId` — the content address a snippet is stored under. It is
//     purely a build-time identifier: build_docs stamps it on the
//     `.playground` div as `data-pg` and the browser only ever echoes it
//     back, so it never has to be recomputed client side.
//   * `snippets` — every snippet on the site, so the precompiler knows what
//     to build and what has gone stale.
//
// `mergedSource` must stay in step with `buildSource` in playground.js. If
// they drift, precompiled output is compiled from different text than the
// reader's edits would produce.

import 'dart:io';

const libraryPath = 'docs/assets/fxdart_single.dart';
const artifactDir = 'docs/pg';

final _fxdartImport = RegExp('''^import\\s+['"]package:fxdart/''');
final _dartImport = RegExp('''^import\\s+['"]dart:''');
final _needsLib = RegExp('''^\\s*import\\s+['"]package:fxdart/''', multiLine: true);

/// Whether `code` pulls in fxdart and therefore needs the single-file bundle
/// prepended. The "native Dart" panels on the comparison pages do not.
bool needsLib(String code) => _needsLib.hasMatch(code);

/// The source the compile service actually sees: `dart:` imports hoisted above
/// the inlined library, the `package:fxdart/` import commented out, and the
/// snippet's own line count preserved so compile errors still map back.
String mergedSource(String lib, String user) {
  final imports = <String>[];
  final body = <String>[];
  for (final line in user.split('\n')) {
    final trimmed = line.trim();
    if (_fxdartImport.hasMatch(trimmed)) {
      body.add('// $line');
    } else if (_dartImport.hasMatch(trimmed)) {
      imports.add(line);
      body.add('// (hoisted) $line');
    } else {
      body.add(line);
    }
  }
  final hoisted = imports.isEmpty ? '' : '${imports.join('\n')}\n';
  return '$hoisted$lib\n// ===== user code below =====\n${body.join('\n')}';
}

/// The snippet text as the browser sees it. build_docs writes the file
/// `trimRight()`ed into a `<textarea>`, and playground.js strips the leading
/// newline back off, so normalize both ends here.
String snippetCode(String raw) =>
    raw.trimRight().replaceFirst(RegExp(r'^\n+'), '');

/// FNV-1a. Not cryptographic — it only has to distinguish snippets from each
/// other. Formatted as two unsigned 32-bit halves because Dart ints are
/// signed, and `toRadixString` on a negative one would put a `-` in a filename.
String fnv1a(String s) {
  var h = 0xcbf29ce484222325;
  for (final c in s.codeUnits) {
    h = ((h ^ c) * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  final hi = (h >> 32) & 0xFFFFFFFF;
  final lo = h & 0xFFFFFFFF;
  return hi.toRadixString(16).padLeft(8, '0') +
      lo.toRadixString(16).padLeft(8, '0');
}

String? _libHashCache;

/// Content hash of the single-file bundle, computed once per process.
String libHash(String root) =>
    _libHashCache ??= fnv1a(File('$root/$libraryPath').readAsStringSync());

final _idCache = <String, String>{};

/// Content address for a snippet. Snippets that do not use fxdart are keyed
/// without the library hash, so rebuilding the bundle does not invalidate the
/// 50 native-Dart comparison panels along with everything else.
String playgroundId(String root, String code) => _idCache.putIfAbsent(code, () {
      final scope = needsLib(code) ? libHash(root) : 'nolib';
      return fnv1a('$scope\u0000$code');
    });

String artifactPath(String root, String id) => '$root/$artifactDir/$id.js.gz';

/// One runnable code block on the site.
class Snippet {
  Snippet(this.path, this.code, this.id, {required this.isFirstOnPage});

  /// Repo-relative source path, for error messages and `--scope` filtering.
  final String path;
  final String code;
  final String id;

  /// The block a reader is most likely to run first: demo 0 of a tutorial, or
  /// either panel of a comparison example (both are on screen together).
  final bool isFirstOnPage;
}

/// The runnable listings of one theory chapter, in reading order.
///
/// The book's listings live inside the manuscript rather than in their own
/// files, and each one is already a complete program (`tool/check_theory.dart`
/// runs them as-is), so the text between the fences is exactly what the
/// browser compiles — no wrapping, no divergence between what is precompiled
/// and what a reader's ▶ Run would produce.
final _runFence = RegExp(r'```dart run\n(.*?)```', dotAll: true);

List<String> theoryListings(String markdown) =>
    _runFence.allMatches(markdown).map((m) => snippetCode(m.group(1)!)).toList();

/// Every playground snippet on the site, in a stable order.
List<Snippet> snippets(String root) {
  final found = <Snippet>[];

  void add(String path, {required bool isFirstOnPage}) {
    final code = snippetCode(File('$root/$path').readAsStringSync());
    found.add(Snippet(path, code, playgroundId(root, code),
        isFirstOnPage: isFirstOnPage));
  }

  final tutorialDirs = Directory('$root/content/code')
      .listSync()
      .whereType<Directory>()
      .map((d) => d.path.split(Platform.pathSeparator).last)
      .toList()
    ..sort();
  for (final slug in tutorialDirs) {
    final files = Directory('$root/content/code/$slug')
        .listSync()
        .whereType<File>()
        .map((f) => f.path.split(Platform.pathSeparator).last)
        .where((n) => RegExp(r'^\d+\.dart$').hasMatch(n))
        .toList()
      ..sort((a, b) => int.parse(a.split('.').first)
          .compareTo(int.parse(b.split('.').first)));
    for (final name in files) {
      add('content/code/$slug/$name', isFirstOnPage: name == files.first);
    }
  }

  for (final (dir, sides) in const [
    ('code-comparison', ['native.dart', 'fxdart.dart']),
    ('code-comparison-rx', ['rxdart.dart', 'fxdart.dart']),
  ]) {
    final base = Directory('$root/content/$dir');
    if (!base.existsSync()) continue;
    final cmpDirs = base
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.split(Platform.pathSeparator).last)
        .toList()
      ..sort();
    for (final slug in cmpDirs) {
      for (final name in sides) {
        final path = 'content/$dir/$slug/$name';
        if (File('$root/$path').existsSync()) add(path, isFirstOnPage: true);
      }
    }
  }

  // The theory book. Every listing counts as first-on-page: the book is a
  // single document a reader walks straight through, so "the one they hit
  // first" is meaningless — waiting on a compile at chapter 12 is exactly as
  // bad as waiting at chapter 1.
  final theoryDir = Directory('$root/content/theory');
  if (theoryDir.existsSync()) {
    final files = theoryDir
        .listSync()
        .whereType<File>()
        .map((f) => f.path.split(Platform.pathSeparator).last)
        .where((n) => RegExp(r'^\d\d-[a-z0-9-]+\.md$').hasMatch(n))
        .toList()
      ..sort();
    for (final name in files) {
      final listings =
          theoryListings(File('$root/content/theory/$name').readAsStringSync());
      for (var i = 0; i < listings.length; i++) {
        found.add(Snippet('content/theory/$name#${i + 1}', listings[i],
            playgroundId(root, listings[i]),
            isFirstOnPage: true));
      }
    }
  }

  return found;
}
