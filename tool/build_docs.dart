// Renders content/ into docs/, once per locale.
//
//   content/                English source of truth (prose + structure)
//   content/code/           playground code + type signatures, locale-invariant
//   i18n/<locale>/          translated overlays; anything absent falls back to English
//   docs/                   generated output, served by GitHub Pages
//
// English renders at the site root so existing URLs never move; every other
// locale renders under its own prefix (docs/ko/, docs/ja/, …).
//
// Run via ./deploy.sh, or directly:
//   dart run tool/build_docs.dart            build everything
//   dart run tool/build_docs.dart --check    fail if docs/ is stale (CI/deploy guard)
//
// NEVER hand-edit docs/*.html — it is generated. Edit content/ or i18n/.

import 'dart:convert';
import 'dart:io';

import 'playground_source.dart' as pg;
import 'theory_markdown.dart';

const siteBase = 'https://bansooknam.github.io/FxDart';
const codemirror = 'https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16';
const dartpad = 'https://stable.api.dartpad.dev';
const repoUrl = 'https://github.com/bansooknam/fxDart';
const fxtsUrl = 'https://github.com/marpple/FxTS';

final root = Directory.current.path;

void main(List<String> args) {
  final check = args.contains('--check');
  final locales = _loadLocales();

  if (args.contains('--record')) return _record(locales);
  if (args.contains('--status')) return _status(locales);
  // The set of translatable pages is derived here and re-derived, by a
  // different route, in check_translation.dart. Both can print it so CI can
  // diff the two and catch them drifting apart.
  if (args.contains('--list-translatable')) {
    (_translatable().toList()..sort()).forEach(stdout.writeln);
    return;
  }

  final course = _loadJson('$root/content/course.json');

  final written = <String, String>{}; // path -> content
  final pages = <_PageRef>[];

  for (final locale in locales) {
    final chrome = _loadChrome(locale);
    final sections = _loadSections(locale);

    // Landing page.
    final index = _loadPage('pages/index.md', locale);
    written[_out(locale, 'index.html')] =
        _renderLanding(locale, locales, chrome, index);
    pages.add(_PageRef(locale, 'index.html', index.translated));

    // 101 course index.
    final course101 = _loadPage('pages/101.md', locale);
    written[_out(locale, '101/index.html')] =
        _render101(locale, locales, chrome, course101, sections, course);
    pages.add(_PageRef(locale, '101/index.html', course101.translated));

    // Tutorials.
    for (final file in _tutorialFiles()) {
      final slug = file.split('/').last.replaceAll('.md', '');
      final page = _loadPage('tutorials/$slug.md', locale);
      written[_out(locale, 'tutorials/$slug.html')] =
          _renderTutorial(locale, locales, chrome, page, sections);
      pages.add(_PageRef(locale, 'tutorials/$slug.html', page.translated));
    }

    // The parallel benchmark: one job, five ways to run it. Standalone
    // rather than a third comparison family — that machinery is built
    // around two sides and a verdict between them, and this page has five
    // sides and no winner to declare.
    final parallelBench = _loadPage('pages/parallel-benchmark.md', locale);
    written[_out(locale, 'parallel-benchmark.html')] =
        _renderParallelBench(locale, locales, chrome, parallelBench);
    pages.add(_PageRef(
        locale, 'parallel-benchmark.html', parallelBench.translated));

    // The theory textbook — one page carrying the whole book.
    final theoryBook = _loadPage('theory/book.md', locale);
    written[_out(locale, 'theory/index.html')] =
        _renderTheoryBook(locale, locales, chrome, theoryBook);
    pages.add(_PageRef(locale, 'theory/index.html', theoryBook.translated));

    // The comparison families: Dart vs FxDart, RxDart vs FxDart.
    for (final family in _cmpFamilies) {
      final cmpIndex = _loadPage(family.indexMd, locale);
      final cmpPages = [
        for (final file in _comparisonFiles(family.contentDir))
          _loadPage('${family.contentDir}/${file.split('/').last}', locale),
      ]..sort((a, b) =>
          int.parse(a.get('order')).compareTo(int.parse(b.get('order'))));
      written[_out(locale, '${family.outDir}/index.html')] =
          _renderComparisonIndex(locale, locales, chrome, cmpIndex, cmpPages,
              family);
      pages.add(_PageRef(
          locale, '${family.outDir}/index.html', cmpIndex.translated));
      for (var i = 0; i < cmpPages.length; i++) {
        final page = cmpPages[i];
        final path = '${family.outDir}/${page.get('slug')}.html';
        written[_out(locale, path)] = _renderComparison(
            locale, locales, chrome, page, family,
            prev: i > 0 ? cmpPages[i - 1] : null,
            next: i < cmpPages.length - 1 ? cmpPages[i + 1] : null);
        pages.add(_PageRef(locale, path, page.translated));
      }
    }
  }

  written['docs/sitemap.xml'] = _renderSitemap(pages, locales);

  if (check) {
    final stale = <String>[];
    written.forEach((path, content) {
      final f = File('$root/$path');
      if (!f.existsSync() || f.readAsStringSync() != content) stale.add(path);
    });
    if (stale.isNotEmpty) {
      stderr.writeln('docs/ is stale — run `dart run tool/build_docs.dart`');
      for (final p in stale.take(10)) {
        stderr.writeln('  $p');
      }
      if (stale.length > 10) stderr.writeln('  … and ${stale.length - 10} more');
      exit(1);
    }
    stdout.writeln('docs/ is up to date (${written.length} files)');
    return;
  }

  _copyStaticSources();

  written.forEach((path, content) {
    final f = File('$root/$path');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(content);
  });

  final translated = pages.where((p) => p.translated).length;
  stdout.writeln('built ${written.length} files across ${locales.length} locales');
  stdout.writeln('$translated/${pages.length} pages translated');
}


/// Copies `web/` — the hand-written half of the site — into the generated
/// `docs/` output.
///
/// `docs/` used to hold both: the ~5,700 rendered pages plus `css/`, `js/`,
/// `frame.html`, the logos and the built Daily Ledger demo. Since everything
/// generated is now built in CI and untracked, the two had to be separated,
/// and `web/` is the tracked half. Layout is preserved verbatim, so
/// `web/css/site.css` lands at `docs/css/site.css` and every relative link a
/// rendered page emits keeps working unchanged.
///
/// A plain copy, not a sync: `build_single_file.sh` and
/// `precompile_playgrounds.dart` also write under `docs/`, and deleting what
/// this function did not put there would throw their output away.
void _copyStaticSources() {
  final src = Directory('$root/web');
  if (!src.existsSync()) {
    stderr.writeln('web/ is missing — the site cannot be assembled without it');
    exit(1);
  }
  for (final entity in src.listSync(recursive: true).whereType<File>()) {
    final rel = entity.path.substring(src.path.length + 1);
    final dest = File('$root/docs/$rel');
    dest.parent.createSync(recursive: true);
    entity.copySync(dest.path);
  }
}

// --- translation bookkeeping ------------------------------------------------

/// Every content file that can be translated, as a path relative to content/.
List<String> _translatable() => [
      'pages/index.md',
      'pages/101.md',
      'pages/parallel-benchmark.md',
      'theory/book.md',
      for (final f in _theoryChapterFiles()) 'theory/${f.split('/').last}',
      for (final family in _cmpFamilies) family.indexMd,
      for (final f in _tutorialFiles()) 'tutorials/${f.split('/').last}',
      for (final family in _cmpFamilies)
        for (final f in _comparisonFiles(family.contentDir))
          '${family.contentDir}/${f.split('/').last}',
    ];

/// Records the current English hash for every existing translation. Run this
/// after a translation pass to say "these are up to date as of now"; from then
/// on any edit to the English source flags the translation as outdated.
void _record(List<Locale> locales) {
  for (final locale in locales.where((l) => !l.isBase)) {
    final recorded = <String, String>{};
    for (final rel in _translatable()) {
      if (!File('$root/i18n/${locale.code}/$rel').existsSync()) continue;
      recorded[rel] = _hash(File('$root/content/$rel').readAsStringSync());
    }
    final out = File('$root/i18n/${locale.code}/sources.json');
    if (recorded.isEmpty && !out.existsSync()) continue;
    out.parent.createSync(recursive: true);
    out.writeAsStringSync('${_prettyJson(recorded)}\n');
    stdout.writeln('${locale.code}: recorded ${recorded.length} sources');
  }
}

/// Per-locale coverage and staleness, so it is obvious what to translate next.
void _status(List<Locale> locales) {
  final all = _translatable();
  stdout.writeln('locale    translated        outdated');
  stdout.writeln('-' * 40);
  for (final locale in locales.where((l) => !l.isBase)) {
    final sources = _sources(locale);
    var done = 0, stale = 0;
    for (final rel in all) {
      if (!File('$root/i18n/${locale.code}/$rel').existsSync()) continue;
      done++;
      final recorded = sources[rel];
      if (recorded != null &&
          recorded != _hash(File('$root/content/$rel').readAsStringSync())) {
        stale++;
      }
    }
    final pct = (done * 100 / all.length).toStringAsFixed(0);
    stdout.writeln('${locale.code.padRight(9)} '
        '${'$done/${all.length}'.padRight(10)} ${'($pct%)'.padRight(6)} '
        '${stale == 0 ? '-' : stale}');
  }
}

String _prettyJson(Map<String, String> m) {
  final keys = m.keys.toList()..sort();
  final body = keys.map((k) => '  ${jsonEncode(k)}: ${jsonEncode(m[k])}').join(',\n');
  return '{\n$body\n}';
}

// --- config -----------------------------------------------------------------

class Locale {
  Locale(this.code, this.name, this.path, this.dir);
  final String code; // BCP 47, used for hreflang and <html lang>
  final String name; // endonym, shown in the switcher
  final String path; // URL prefix; empty for English (site root)
  final String dir; // 'ltr' or 'rtl'

  bool get isBase => path.isEmpty;
  int get depth => isBase ? 0 : 1;
}

List<Locale> _loadLocales() {
  final raw = _loadJson('$root/content/locales.json') as List;
  return raw
      .map((e) => Locale(e['code'], e['name'], e['path'] ?? '', e['dir'] ?? 'ltr'))
      .toList();
}

dynamic _loadJson(String path) => jsonDecode(File(path).readAsStringSync());

/// ARB carries `@key` metadata blocks (nested objects) alongside the strings;
/// strip them so the result is a flat string map.
Map<String, String> _arb(String json) {
  final raw = jsonDecode(json) as Map<String, dynamic>;
  return {
    for (final e in raw.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

Map<String, String> _loadChrome(Locale locale) {
  final base = _arb(File('$root/content/chrome.arb').readAsStringSync());
  if (locale.isBase) return base;
  final f = File('$root/i18n/${locale.code}/chrome.arb');
  // Untranslated keys fall back to English rather than rendering blank.
  if (f.existsSync()) base.addAll(_arb(f.readAsStringSync()));
  return base;
}

Map<String, String> _loadSections(Locale locale) {
  final base = Map<String, String>.from(_loadJson('$root/content/sections.json'));
  if (locale.isBase) return base;
  final f = File('$root/i18n/${locale.code}/sections.json');
  if (f.existsSync()) {
    base.addAll(Map<String, String>.from(jsonDecode(f.readAsStringSync())));
  }
  return base;
}

List<String> _tutorialFiles() => (Directory('$root/content/tutorials')
        .listSync()
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('.md'))
        .toList()
      ..sort());

List<String> _comparisonFiles(String contentDir) {
  final dir = Directory('$root/content/$contentDir');
  if (!dir.existsSync()) return const [];
  return dir
      .listSync()
      .whereType<File>()
      .map((f) => f.path)
      .where((p) => p.endsWith('.md'))
      .toList()
    ..sort();
}

// --- content ----------------------------------------------------------------

class Page {
  Page(this.meta, this.body, this.translated, this.stale);
  final Map<String, String> meta;
  final String body;
  final bool translated;

  /// True when a translation exists but the English source has changed since
  /// it was recorded (see `--record`). The translation is still shown — a
  /// slightly outdated translation beats an untranslated page — but the reader
  /// is told, and the writer can find it with `--status`.
  final bool stale;

  String get(String key, [String fallback = '']) => meta[key] ?? fallback;
}

/// Loads `relPath` for `locale`, falling back to the English source when no
/// translation exists. `translated` reports which happened — the caller uses it
/// to add the "not yet translated" banner and a canonical link to English.
Page _loadPage(String relPath, Locale locale) {
  var file = File('$root/content/$relPath');
  var translated = locale.isBase;

  if (!locale.isBase) {
    final localized = File('$root/i18n/${locale.code}/$relPath');
    if (localized.existsSync()) {
      file = localized;
      translated = true;
    }
  }

  final raw = file.readAsStringSync();
  final end = raw.indexOf('\n---\n', 4);
  if (!raw.startsWith('---\n') || end == -1) {
    throw StateError('$relPath: missing front matter');
  }

  final meta = _frontMatter(raw);

  // Strip blank lines only — the first content line's indentation is part of
  // the <main> layout and must survive the round trip.
  final body = raw
      .substring(end + 5)
      .replaceAll(RegExp(r'^\s*\n'), '')
      .replaceAll(RegExp(r'\s+$'), '');
  if (translated && !locale.isBase) {
    final english = File('$root/content/$relPath').readAsStringSync();

    // A translation that drops or renumbers a {{playground:N}} would silently
    // lose a code sample, so parity with the English source is a build error.
    final expected = _placeholders.allMatches(english).map((m) => m[0]).toList();
    final actual = _placeholders.allMatches(body).map((m) => m[0]).toList();
    if (!_sameOrder(expected, actual)) {
      throw StateError('i18n/${locale.code}/$relPath: placeholder mismatch\n'
          '  expected: $expected\n'
          '  found:    $actual');
    }

    // `title`, `description`, and `heading` are prose. Everything else is
    // structure — function names and link targets — and a translated `next:`
    // would quietly break the tutorial chain for that language only.
    // (Tutorial `heading` values happen to be `<code>fnName</code>` snippets,
    // so they naturally match English anyway; comparison-page `heading`
    // values are plain sentences that genuinely need translating.)
    final enMeta = _frontMatter(english);
    for (final key in enMeta.keys.toList()..addAll(meta.keys)) {
      if (key == 'title' || key == 'description' || key == 'heading') {
        continue;
      }
      if (enMeta[key] != meta[key]) {
        throw StateError('i18n/${locale.code}/$relPath: front matter `$key` '
            'must match English exactly (it is structure, not prose)\n'
            '  English: ${enMeta[key]}\n'
            '  Found:   ${meta[key]}');
      }
    }
  }

  var stale = false;
  if (translated && !locale.isBase) {
    final recorded = _sources(locale)[relPath];
    // A translation with no recorded baseline predates tracking; don't cry wolf.
    if (recorded != null) {
      stale = recorded != _hash(File('$root/content/$relPath').readAsStringSync());
    }
  }

  return Page(meta, body, translated, stale);
}

/// FNV-1a. Only ever compared for equality against a previously recorded value,
/// so a non-cryptographic hash is the right tool and keeps the package
/// dependency-free.
String _hash(String s) {
  var h = 0xcbf29ce484222325;
  for (final c in s.codeUnits) {
    h = ((h ^ c) * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return h.toRadixString(16).padLeft(16, '0');
}

final _sourcesCache = <String, Map<String, String>>{};

/// Maps a content path to the hash of the English source its translation was
/// made from.
Map<String, String> _sources(Locale locale) =>
    _sourcesCache.putIfAbsent(locale.code, () {
      final f = File('$root/i18n/${locale.code}/sources.json');
      if (!f.existsSync()) return <String, String>{};
      return Map<String, String>.from(jsonDecode(f.readAsStringSync()));
    });

final _placeholders =
    RegExp(r'\{\{(?:root|signature|playground:\d+|comparison|output)\}\}');

bool _sameOrder(List<String?> a, List<String?> b) =>
    a.length == b.length && List.generate(a.length, (i) => a[i] == b[i]).every((x) => x);

/// Parses the `---` fenced front matter at the top of a content file.
Map<String, String> _frontMatter(String raw) {
  final end = raw.indexOf('\n---\n', 4);
  if (!raw.startsWith('---\n') || end == -1) return {};
  final meta = <String, String>{};
  for (final line in raw.substring(4, end).split('\n')) {
    final i = line.indexOf(':');
    if (i > 0) meta[line.substring(0, i).trim()] = line.substring(i + 1).trim();
  }
  return meta;
}

/// Substitutes the locale-invariant code blocks back into the prose, and
/// resolves {{root}} to the site root. Shared assets live once at the site root
/// (docs/assets/), not per locale, so a bare `assets/x.png` in a translated page
/// would resolve to the non-existent `docs/<locale>/assets/`.
String _injectCode(String body, String slug, int depth) {
  final dir = '$root/content/code/$slug';

  body = body.replaceAll('{{root}}', _rel(depth));

  body = body.replaceAll('{{signature}}', () {
    final f = File('$dir/sig.txt');
    return f.existsSync()
        ? '<div class="signature">${f.readAsStringSync().trimRight()}</div>'
        : '';
  }());

  return body.replaceAllMapped(RegExp(r'\{\{playground:(\d+)\}\}'), (m) {
    final f = File('$dir/${m.group(1)}.dart');
    if (!f.existsSync()) throw StateError('$slug: missing code ${m.group(1)}.dart');
    final code = pg.snippetCode(f.readAsStringSync());
    return '<div class="playground"${_pgAttr(code)}>\n'
        '<textarea>\n$code\n</textarea>\n  </div>';
  });
}

/// `data-pg` points playground.js at the artifact tool/precompile_playgrounds
/// built for this exact snippet, letting an unedited Run skip the compile
/// service entirely. Emitted only when the artifact is actually on disk, so a
/// site built without precompiling still renders — it just falls back to
/// compiling over the network, and `--check` stays deterministic for whatever
/// docs/pg/ currently holds.
String _pgAttr(String code) {
  if (!File('$root/${pg.libraryPath}').existsSync()) return '';
  final id = pg.playgroundId(root, code);
  return File(pg.artifactPath(root, id)).existsSync() ? ' data-pg="$id"' : '';
}

/// Site-root-relative URL of the playground's fxdart bundle, fingerprinted so
/// a redeployed library can never be served from a stale cache entry. GitHub
/// Pages will not let us set immutable caching headers, but a changing URL
/// gets the same guarantee.
String _libUrl() {
  const path = 'assets/fxdart_single.dart';
  if (!File('$root/${pg.libraryPath}').existsSync()) return path;
  return '$path?v=${pg.libHash(root)}';
}

// --- templates --------------------------------------------------------------

String _rel(int depth) => '../' * depth;

/// Output path for `page` in `locale`, relative to the repo root.
String _out(Locale locale, String page) =>
    locale.isBase ? 'docs/$page' : 'docs/${locale.path}/$page';

/// Public URL for `page` in `locale`.
String _url(Locale locale, String page) {
  final p = page == 'index.html' ? '' : page;
  return locale.isBase ? '$siteBase/$p' : '$siteBase/${locale.path}/$p';
}

String _head(
  Locale locale,
  List<Locale> locales,
  Page page,
  String pagePath,
  int depth, {
  bool playground = true,
}) {
  final p = _rel(depth);
  final b = StringBuffer()
    ..writeln('<!DOCTYPE html>')
    ..writeln('<html lang="${locale.code}"${locale.dir == 'rtl' ? ' dir="rtl"' : ''}>')
    ..writeln('<head>')
    ..writeln('  <meta charset="utf-8">')
    ..writeln('  <meta name="viewport" content="width=device-width, initial-scale=1">')
    ..writeln('  <title>${page.get('title')}</title>')
    ..writeln('  <meta name="description" content="${page.get('description')}">');

  // An untranslated page is English prose at a localized URL — point search
  // engines at the English original so the duplicate does not compete with it.
  if (!page.translated) {
    b.writeln('  <link rel="canonical" href="${_url(locales.first, pagePath)}">');
  }
  for (final l in locales) {
    b.writeln('  <link rel="alternate" hreflang="${l.code}" href="${_url(l, pagePath)}">');
  }
  b.writeln('  <link rel="alternate" hreflang="x-default" '
      'href="${_url(locales.first, pagePath)}">');

  b.writeln('  <link rel="stylesheet" href="${p}css/site.css">');
  if (playground) {
    b.writeln('  <link rel="stylesheet" href="$codemirror/codemirror.min.css">');
    // The DDC runtime comes from here, and it is the long pole on a reader's
    // first Run — get DNS, TCP and TLS out of the way while the page renders.
    b.writeln('  <link rel="preconnect" href="$dartpad" crossorigin>');
    // Only needed once a reader edits a snippet, so fetch it at prefetch
    // priority while they read rather than on the click that needs it.
    b.writeln('  <link rel="prefetch" href="$p${_libUrl()}">');
  }
  b
    ..writeln('</head>')
    ..writeln('<body>');
  return b.toString();
}

String _header(
  Locale locale,
  List<Locale> locales,
  Map<String, String> chrome,
  String pagePath,
  int depth,
  String active,
) {
  // Site-root-relative: shared assets (one css/ and js/ for every locale).
  // Locale-root-relative: navigation, so a reader stays in their language
  // instead of being dropped onto the English page by the Home link.
  final p = _rel(depth - locale.depth);
  String cls(String name) => active == name ? ' class="active"' : '';
  final apiHref = active == '101' ? '#api' : '${p}101/index.html#api';

  return '''
<header class="site-header">
  <div class="inner">
    <a class="logo" href="${p}index.html">Fx<span>Dart</span></a>
    <nav>
      <a href="${p}index.html"${cls('home')}>${chrome['navHome']}</a>
      <a href="${p}101/index.html"${cls('101')}>${chrome['nav101']}</a>
      <a href="${p}theory/index.html"${cls('theory')}>${chrome['navTheory']}</a>
      <a href="${p}DartComparison/index.html"${cls('compare')}>${chrome['navCompare']}</a>
      <a href="${p}RxDartComparison/index.html"${cls('compareRx')}>${chrome['navCompareRx']}</a>
      <a href="$apiHref">${chrome['navApi']}</a>
      <a href="$repoUrl">GitHub</a>
      <a href="$fxtsUrl">FxTS</a>
    </nav>
${_switcher(locale, locales, chrome, pagePath, depth)}  </div>
</header>
''';
}

/// Where the switcher should point for `to`, as a path relative to the current
/// page. Relative rather than absolute so the site works unchanged from a local
/// preview server, a project subpath (/FxDart/), or a custom domain — only the
/// hreflang/canonical tags need to be absolute, and those are built separately.
String _switcherHref(int depth, Locale to, String pagePath) =>
    '${_rel(depth)}${to.isBase ? '' : '${to.path}/'}$pagePath';

/// Plain links, not a <select> — works without JS, and crawlers follow it.
String _switcher(
  Locale locale,
  List<Locale> locales,
  Map<String, String> chrome,
  String pagePath,
  int depth,
) {
  final b = StringBuffer()
    ..writeln('    <nav class="lang-switcher" aria-label="${chrome['langLabel']}">')
    ..writeln('      <span class="lang-label">${chrome['langLabel']}</span>')
    ..writeln('      <ul>');
  for (final l in locales) {
    final current = l.code == locale.code;
    // `lang` on the link tells the browser to render each endonym with the
    // right font stack; `hreflang` tells crawlers what they will land on.
    b.writeln('        <li><a href="${_switcherHref(depth, l, pagePath)}" hreflang="${l.code}" lang="${l.code}"'
        '${current ? ' aria-current="page"' : ''}>${l.name}</a></li>');
  }
  b
    ..writeln('      </ul>')
    ..writeln('    </nav>');
  return b.toString();
}

String _banner(Map<String, String> chrome, Page page) {
  final message = page.translated
      ? (page.stale ? chrome['outdated'] : null)
      : chrome['untranslated'];
  if (message == null) return '';
  return '  <p class="i18n-banner">$message '
      '<a href="${chrome['contributeUrl']}">${chrome['contributeCta']}</a></p>\n';
}

String _footer(Map<String, String> chrome) => '''
<footer class="site-footer">
  <p>${chrome['footerCredit']}</p>
  <p>${chrome['footerLegal']}</p>
</footer>
''';

String _scripts(Locale locale, Map<String, String> chrome, int depth) {
  final p = _rel(depth);
  // playground.js stays locale-agnostic; it reads these at runtime.
  final strings = const [
    'pgRun',
    'pgReset',
    'pgCompiling',
    'pgCompileError',
    'pgError',
    'pgLoading',
    'pgRunning',
    'pgNoOutput',
    'pgLoadFailed',
  ];
  final map = {for (final k in strings) k: chrome[k] ?? ''};
  return '''
<script>window.FXDART_I18N = ${jsonEncode(map)};
window.FXDART_LIB = ${jsonEncode(_libUrl())};</script>
<script src="$codemirror/codemirror.min.js"></script>
<script src="$codemirror/mode/clike/clike.min.js"></script>
<script src="$codemirror/mode/dart/dart.min.js"></script>
<script src="${p}js/playground.js" defer></script>
</body>
</html>
''';
}

// --- page renderers ---------------------------------------------------------

String _renderLanding(
  Locale locale,
  List<Locale> locales,
  Map<String, String> chrome,
  Page page,
) {
  final depth = locale.depth;
  final b = StringBuffer()
    ..write(_head(locale, locales, page, 'index.html', depth))
    ..write(_header(locale, locales, chrome, 'index.html', depth, 'home'))
    ..writeln('<main>')
    ..write(_banner(chrome, page))
    ..writeln(_injectCode(page.body, '_index', depth))
    ..writeln('</main>')
    ..write(_footer(chrome))
    ..write(_scripts(locale, chrome, depth));
  return b.toString();
}

String _render101(
  Locale locale,
  List<Locale> locales,
  Map<String, String> chrome,
  Page page,
  Map<String, String> sections,
  dynamic course,
) {
  final depth = locale.depth + 1;
  final b = StringBuffer()
    ..write(_head(locale, locales, page, '101/index.html', depth, playground: false))
    ..write(_header(locale, locales, chrome, '101/index.html', depth, '101'))
    ..writeln('<main>')
    ..write(_banner(chrome, page))
    ..writeln(page.body.replaceAll('{{root}}', _rel(depth)));

  final keys = (course as Map).keys.toList()
    ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  for (final n in keys) {
    // The #api anchor lands on the first section — it is the nav's jump target.
    final id = n == keys.first ? ' id="api"' : '';
    b
      ..writeln('')
      ..writeln('  <h2$id>${chrome['sectionWord']} $n · ${sections['section$n']}</h2>')
      ..writeln('  <p class="dim">${sections['section${n}Blurb']}</p>')
      ..writeln('  <ul class="fn-list">');
    for (final fn in course[n]) {
      b.writeln('    <li><a href="../tutorials/${fn['href']}">${fn['label']}</a></li>');
    }
    b.writeln('  </ul>');
  }

  b
    ..writeln('</main>')
    ..write(_footer(chrome))
    ..writeln('</body>')
    ..writeln('</html>');
  return b.toString();
}

String _renderTutorial(
  Locale locale,
  List<Locale> locales,
  Map<String, String> chrome,
  Page page,
  Map<String, String> sections,
) {
  final depth = locale.depth + 1;
  final slug = page.get('slug');
  final path = 'tutorials/$slug.html';
  final section = page.get('section');
  final p = _rel(depth);

  final b = StringBuffer()
    ..write(_head(locale, locales, page, path, depth))
    ..write(_header(locale, locales, chrome, path, depth, ''))
    ..writeln('<main>')
    ..write(_banner(chrome, page))
    ..writeln('  <p class="breadcrumb">'
        '<a href="${p}101/index.html">${chrome['crumb101']}</a> › '
        '${chrome['sectionWord']} $section · ${sections['section$section']} › '
        '<strong>${page.get('crumb')}</strong></p>')
    ..writeln('  <h1>${page.get('heading')}</h1>')
    ..writeln(_injectCode(page.body, slug, depth))
    ..writeln('')
    ..writeln('  <nav class="tut-nav">');
  // Section-opening pages have no predecessor and link back to the course.
  if (page.meta.containsKey('prev')) {
    b.writeln('    <a href="${page.get('prev')}">'
        '← ${chrome['prevPrefix']}${page.get('prevLabel')}</a>');
  } else {
    b.writeln('    <a href="${p}101/index.html">← ${chrome['crumb101']}</a>');
  }
  if (page.meta.containsKey('next')) {
    b.writeln('    <a href="${page.get('next')}">'
        '${chrome['nextPrefix']}${page.get('nextLabel')} →</a>');
  }
  b
    ..writeln('  </nav>')
    ..writeln('</main>')
    ..write(_footer(chrome))
    ..write(_scripts(locale, chrome, depth));
  return b.toString();
}

// --- theory textbook ----------------------------------------------------------
//
// content/theory/ holds a book: `book.md` (the preface pages) plus numbered
// chapter files. Unlike the rest of the site it renders to a *single* page —
// docs/theory/index.html — because the reader turns pages inside it rather
// than navigating between URLs. tool/theory_markdown.dart converts the
// manuscript to blocks; web/js/theorybook.js flows them into pages at
// runtime, where the viewport size is finally known.

/// Chapter manuscripts, in reading order. Only `NN-slug.md` counts — `book.md`
/// is the preface and `PLAN.md` is the writing plan, neither of which is a
/// chapter.
/// Whether `locale` has its own edition of the theory book.
///
/// Keyed on the preface (`theory/book.md`) — the same file the page's own
/// "not translated" banner is keyed on, so the switcher and the banner can
/// never disagree.
bool _hasTheoryBook(Locale locale) =>
    locale.isBase ||
    File('$root/i18n/${locale.code}/theory/book.md').existsSync();

List<String> _theoryChapterFiles() {
  final dir = Directory('$root/content/theory');
  if (!dir.existsSync()) return const [];
  final chapter = RegExp(r'^\d\d-[a-z0-9-]+\.md$');
  return (dir.listSync().whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path)))
      .map((f) => f.path)
      .where((p) => chapter.hasMatch(p.split('/').last))
      .toList();
}

/// `data-pg="<id>"` for a book listing that has a precompiled artifact, so the
/// reader's ▶ Run fetches ~60KB of gzipped JS instead of waiting on a compile.
/// Empty when the artifact is missing — the run path then falls back to the
/// compile service exactly as before.
String _theoryArtifactAttr(String code) {
  if (!File('$root/${pg.libraryPath}').existsSync()) return '';
  final id = pg.playgroundId(root, code);
  return File(pg.artifactPath(root, id)).existsSync() ? ' data-pg="$id"' : '';
}

/// Part titles, translated like sections.json. Keys are the part number and
/// `<n>Blurb`; a chapter's `part:` front matter selects one.
Map<String, String> _loadTheoryParts(Locale locale) {
  final base = Map<String, String>.from(_loadJson('$root/content/theory/parts.json'));
  if (locale.isBase) return base;
  final f = File('$root/i18n/${locale.code}/theory/parts.json');
  if (!f.existsSync()) return base;
  return base..addAll(Map<String, String>.from(jsonDecode(f.readAsStringSync())));
}

String _renderTheoryBook(
  Locale locale,
  List<Locale> locales,
  Map<String, String> chrome,
  Page book,
) {
  final depth = locale.depth + 1;
  final p = _rel(depth);
  final parts = _loadTheoryParts(locale);
  final diagrams = '$root/content/theory/diagrams';

  final blocks = <String>[];

  // Preface: the pages before chapter 1. Chapter 0 never prints a number.
  blocks.add('<div class="title-page">'
      '<h1>${chrome['theoryTitle']}</h1>'
      '<p class="sub">${chrome['theorySubtitle']}</p>'
      '<p class="byline">${chrome['theoryByline']}</p></div>');
  blocks.addAll(convertChapter(book.body,
          number: 0, title: chrome['theoryTitle'] ?? '', diagramsDir: diagrams)
      .blocks);

  var lastPart = '';
  for (final file in _theoryChapterFiles()) {
    final rel = 'theory/${file.split('/').last}';
    final page = _loadPage(rel, locale);
    final part = page.get('part');
    final newPart = part.isNotEmpty && part != lastPart;
    if (newPart) lastPart = part;
    blocks.addAll(convertChapter(
      page.body,
      number: int.parse(page.get('chapter')),
      title: page.get('title'),
      diagramsDir: diagrams,
      partLabel: newPart ? parts['part$part'] : null,
      partBlurb: newPart ? parts['part${part}Blurb'] : null,
      artifact: _theoryArtifactAttr,
    ).blocks);
  }

  final strings = {
    'toc': chrome['theoryToc'] ?? 'Contents',
    'run': chrome['theoryRun'] ?? '▶ Run',
    'output': chrome['theoryOutput'] ?? 'Output',
    'close': chrome['theoryClose'] ?? 'Close',
    'compiling': chrome['pgCompiling'] ?? 'Compiling…',
    'running': chrome['pgRunning'] ?? 'Running…',
    'noOutput': chrome['pgNoOutput'] ?? '(no output)',
    'runUnavailable': chrome['theoryRunUnavailable'] ?? '',
    'edit': chrome['theoryEdit'] ?? '✎ Edit',
    'editTitle': chrome['theoryEditTitle'] ?? 'Edit and run',
    'reset': chrome['theoryReset'] ?? 'Reset',
    'edited': chrome['theoryEdited'] ?? 'edited',
    'goto': chrome['theoryGoto'] ?? 'Go to page',
    'go': chrome['theoryGo'] ?? 'Go',
    'lang': chrome['langLabel'] ?? 'Language',
  };
  final pgStrings = {
    for (final k in const ['pgCompileError', 'pgError', 'pgLoadFailed'])
      k: chrome[k] ?? '',
  };

  // The book is a standalone document: no site.css, no site header, no shared
  // scripts beyond the playground engine. It fills the viewport and owns every
  // pixel, which is what keeps the site's theme tokens, nav and layout out of
  // the page box — the reader leaves through the close button.
  final b = StringBuffer()
    ..writeln('<!DOCTYPE html>')
    ..writeln('<html lang="${locale.code}"'
        '${locale.dir == 'rtl' ? ' dir="rtl"' : ''}>')
    ..writeln('<head>')
    ..writeln('  <meta charset="utf-8">')
    ..writeln('  <meta name="viewport" content="width=device-width, '
        'initial-scale=1">')
    ..writeln('  <title>${book.get('title')}</title>')
    ..writeln('  <meta name="description" content="${book.get('description')}">');
  if (!book.translated) {
    b.writeln('  <link rel="canonical" '
        'href="${_url(locales.first, 'theory/index.html')}">');
  }
  for (final l in locales) {
    b.writeln('  <link rel="alternate" hreflang="${l.code}" '
        'href="${_url(l, 'theory/index.html')}">');
  }
  b
    ..writeln('  <link rel="alternate" hreflang="x-default" '
        'href="${_url(locales.first, 'theory/index.html')}">')
    ..writeln('  <link rel="stylesheet" href="${p}css/theorybook.css">')
    ..writeln('  <link rel="preconnect" href="$dartpad" crossorigin>')
    ..writeln('  <link rel="prefetch" href="$p${_libUrl()}">')
    ..writeln('</head>')
    ..writeln('<body class="book-standalone">')
    ..writeln('  <div id="book-stage">')
    ..writeln('    <div id="scaler">')
    ..writeln('      <div id="book">')
    ..writeln('        <div class="board"></div>')
    ..writeln('        <div id="sheets"></div>')
    ..writeln('        <div class="spine"></div>')
    ..writeln('      </div>')
    ..writeln('    </div>')
    // Single-page mode has no facing page to say which chapter this is, so
    // the crumb does; the spread hides it.
    ..writeln('    <span id="book-crumb"></span>')
    // Locale-root-relative, like the site nav: closing the Korean book must
    // land on the Korean course, not drop the reader into English.
    ..writeln('    <a id="book-close" '
        'href="${_rel(depth - locale.depth)}101/index.html" '
        'aria-label="${chrome['theoryClose']}" '
        'title="${chrome['theoryClose']}">✕</a>')
    ..writeln('    <button id="nav-prev" class="book-nav" type="button" '
        'aria-label="${chrome['theoryPrev']}">‹</button>')
    ..writeln('    <button id="nav-next" class="book-nav" type="button" '
        'aria-label="${chrome['theoryNext']}">›</button>')
    ..writeln('    <div id="book-hud">')
    ..writeln('      <span id="page-indicator"></span>')
    ..writeln('      <button id="toc-btn" type="button">'
        '${chrome['theoryToc']}</button>')
    // The page picker: single-page mode's middle control, which also carries
    // the page indicator there. Hidden while a spread is showing.
    ..writeln('      <button id="goto-btn" type="button" '
        'aria-label="${chrome['theoryGoto']}"></button>')
    // Its neighbour: the language switch. A spread lists every edition along
    // the foot of the page, but the bar has room for a glyph and the tag of
    // the edition being read, so on a phone the list moves into a sheet.
    ..writeln('      <button id="lang-btn" type="button" '
        'aria-label="${chrome['langLabel']}">'
        '<svg viewBox="0 0 20 20" width="15" height="15" aria-hidden="true" '
        'fill="none" stroke="currentColor" stroke-width="1.4">'
        '<circle cx="10" cy="10" r="8"></circle><path d="M2 10h16"></path>'
        '<path d="M10 2c2.2 2.3 3.4 5 3.4 8s-1.2 5.7-3.4 8'
        'c-2.2-2.3-3.4-5-3.4-8S7.8 4.3 10 2z"></path></svg>'
        '<span>${locale.code.split('-').first.toUpperCase()}</span></button>');
  // The standalone page has no room for the site's translation banner, but a
  // reader handed an English book inside a localized shell still deserves to
  // be told why.
  if (!book.translated || book.stale) {
    final message = book.translated ? chrome['outdated'] : chrome['untranslated'];
    b.writeln('      <a class="book-note" href="${chrome['contributeUrl']}">'
        '$message</a>');
  }
  // Only the editions that exist. The book is a 300-page manuscript, so a
  // locale with no `i18n/<code>/theory/` is not a translation of it — offering
  // 日本語 that lands on the same English pages is a promise the switcher
  // cannot keep. The locale being read stays listed either way, so a reader
  // who arrived on one of those pages can still see where they are.
  b.writeln('      <nav class="book-langs" '
      'aria-label="${chrome['langLabel']}">');
  for (final l in locales) {
    if (!_hasTheoryBook(l) && l.code != locale.code) continue;
    final href =
        '${_rel(depth)}${l.isBase ? '' : '${l.path}/'}theory/index.html';
    b.writeln('        <a href="$href" hreflang="${l.code}" lang="${l.code}"'
        '${l.code == locale.code ? ' aria-current="page"' : ''}>'
        '${l.name}</a>');
  }
  // …and how to add one. No hreflang: this leaves the book, and the anchor
  // that carries the reading position between editions must not follow it.
  b
    ..writeln('        <a class="book-contribute" '
        'href="${chrome['contributeUrl']}" target="_blank" rel="noopener">'
        '${chrome['theoryContribute']}</a>')
    ..writeln('      </nav>')
    ..writeln('    </div>')
    ..writeln('  </div>')
    ..writeln('  <template id="cover-art">')
    ..writeln('    <div class="hc-face hc-front"><div class="hc-frame">')
    ..writeln('      <div class="hc-mark">FXDART 101</div>')
    ..writeln('      <h1>${chrome['theoryTitle']}</h1>')
    ..writeln('      <div class="sub">${chrome['theorySubtitle']}</div>')
    ..writeln('      <div class="author">${chrome['theoryByline']}</div>')
    ..writeln('    </div></div>')
    ..writeln('  </template>')
    // Without JS the book cannot paginate, so the manuscript is simply shown
    // as one long page — every word stays readable (and indexable).
    ..writeln('  <noscript><style>#book-stage{display:none}'
        '#source{display:block;max-width:46rem;margin:2rem auto;'
        'padding:1.5rem 1.75rem;background:var(--paper);color:var(--fp-ink);'
        'border-radius:10px}'
        '</style></noscript>')
    ..writeln('  <div id="source">');
  for (final block in blocks) {
    b.writeln('    $block');
  }
  b
    ..writeln('  </div>')
    ..writeln('<script>window.FXDART_I18N = ${jsonEncode(pgStrings)};')
    ..writeln('window.FXDART_LIB = ${jsonEncode(_libUrl())};')
    ..writeln('window.FXDART_THEORY = ${jsonEncode(strings)};</script>')
    ..writeln('<script src="${p}js/playground.js" defer></script>')
    ..writeln('<script src="${p}js/theorybook.js" defer></script>')
    ..writeln('</body>')
    ..writeln('</html>');
  return b.toString();
}

// --- comparison families ------------------------------------------------------
//
// The site carries two side-by-side comparison sections built from the same
// machinery: Dart vs FxDart (the original) and RxDart vs FxDart. A family
// bundles everything that differs between them — directories, the left-hand
// panel, chrome keys, verdict vocabulary — so the renderers stay shared.

class _CmpFamily {
  const _CmpFamily({
    required this.contentDir,
    required this.codeDir,
    required this.indexMd,
    required this.outDir,
    required this.leftFile,
    required this.leftKey,
    required this.leftSide,
    required this.navActive,
    required this.navKey,
    required this.crumbKey,
    required this.tierPrefix,
    required this.verdictKeys,
    required this.picks,
    required this.bench,
    required this.benchResults,
    required this.benchWinLeftKey,
    required this.benchSpeedLeftKey,
    required this.benchScales,
  });

  final String contentDir; // page markdown under content/
  final String codeDir; // code + expected.txt under content/
  final String indexMd; // the TOC page source
  final String outDir; // docs/<outDir>/
  final String leftFile; // left panel source file name
  final String leftKey; // chrome key of the left panel heading
  final String leftSide; // css suffix of the left panel
  final String navActive; // header active-tab id
  final String navKey; // chrome key of the header tab label
  final String crumbKey; // chrome key of the breadcrumb / back link
  final String tierPrefix; // chrome key prefix of the tier headings
  final Map<String, String> verdictKeys; // verdict value -> chrome key
  final List<int> picks; // orders of the curated "read these" list
  final bool bench; // whether pages get a Benchmark section
  final String benchResults; // benchmark/results/<file> for this family
  final String benchWinLeftKey; // chrome key of the left side's win badge
  final String benchSpeedLeftKey; // chrome key of the left side's index speed badge
  final List<String> benchScales; // scale-block order, small → large
}

const _cmpFamilies = [
  _CmpFamily(
    contentDir: 'comparison',
    codeDir: 'code-comparison',
    indexMd: 'pages/comparison.md',
    outDir: 'DartComparison',
    leftFile: 'native.dart',
    leftKey: 'cmpNative',
    leftSide: 'native',
    navActive: 'compare',
    navKey: 'navCompare',
    crumbKey: 'crumbCompare',
    tierPrefix: 'cmpTier',
    verdictKeys: {
      'fxdart': 'cmpVerdictFxdart',
      'tie': 'cmpVerdictTie',
      'native': 'cmpVerdictNative',
    },
    // Orders, not slugs — reordering a Part reassigns these, so they are
    // re-picked whenever an ordering pass runs (see plans/CMP_ORDERING_RULE.md).
    // 1/11/23 are the leaders of Parts 1–3; Part 4 is laid out as a reverse
    // pyramid, so its two best sit at its last and first rows (53 and 31).
    picks: [1, 11, 23, 31, 53],
    bench: true,
    benchResults: 'results.json',
    benchWinLeftKey: 'cmpBenchWinNative',
    benchSpeedLeftKey: 'cmpSpeedNative',
    benchScales: ['100', '10000', 'full'],
  ),
  _CmpFamily(
    contentDir: 'comparison-rx',
    codeDir: 'code-comparison-rx',
    indexMd: 'pages/comparison-rx.md',
    outDir: 'RxDartComparison',
    leftFile: 'rxdart.dart',
    leftKey: 'cmpRxdart',
    leftSide: 'rxdart',
    navActive: 'compareRx',
    navKey: 'navCompareRx',
    crumbKey: 'crumbCompareRx',
    tierPrefix: 'cmpRxTier',
    verdictKeys: {
      'fxdart': 'cmpVerdictFxdart',
      'tie': 'cmpVerdictTie',
      'rxdart': 'cmpVerdictRxdart',
    },
    // Orders, not slugs — see the DartComparison note above. 1/11/25 lead
    // Parts 1–3; Part 4 is a reverse pyramid, so its two best are its first
    // and last rows (35 and 50).
    picks: [1, 11, 25, 35, 50],
    bench: true,
    benchResults: 'results-rx.json',
    benchWinLeftKey: 'cmpBenchWinRxdart',
    benchSpeedLeftKey: 'cmpSpeedRxdart',
    benchScales: ['100', 'full'],
  ),
];

String _escapeHtml(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// The verdict badge (and, for async examples, the async badge). The verdict
/// is structure, not prose — an unknown value is a typo, not a new category.
String _cmpBadges(Map<String, String> chrome, Page page, _CmpFamily family) {
  final verdict = page.get('verdict');
  final key = family.verdictKeys[verdict];
  if (key == null) {
    throw StateError('${page.get('slug')}: unknown verdict `$verdict` '
        '(expected one of: ${family.verdictKeys.keys.join(', ')})');
  }
  final b = StringBuffer(
      '<span class="badge verdict-$verdict">${chrome[key]}</span>');
  if (page.get('async') == 'true') {
    b.write(' <span class="badge badge-async">${chrome['cmpAsyncBadge']}</span>');
  }
  return b.toString();
}

/// The measured time winner at the family's largest benchmark scale, or null
/// when the case has no recorded results (a new example that simply hasn't
/// been measured yet — not an error).
String? _cmpSpeedWinner(_CmpFamily family, String slug) {
  final data = _benchResults(family.benchResults);
  final c =
      (data?['cases'] as Map<String, dynamic>?)?[slug] as Map<String, dynamic>?;
  final s = (c?['scales'] as Map<String, dynamic>?)?[family.benchScales.last]
      as Map<String, dynamic>?;
  if (s == null || s.containsKey('error')) return null;
  return s['timeWinner'] as String?;
}

/// The measured-speed badge for index rows — the second standpoint next to
/// the code verdict. Deliberately distinct three ways from the filled verdict
/// badge (outlined, ⚡-prefixed, "faster"/"same speed" wording) so a reader
/// never mistakes the editorial judgment for the measurement or vice versa.
String _cmpSpeedBadge(
    Map<String, String> chrome, _CmpFamily family, String slug) {
  final winner = _cmpSpeedWinner(family, slug);
  if (winner == null) return '';
  final key = {
    family.leftSide: family.benchSpeedLeftKey,
    'fxdart': 'cmpSpeedFxdart',
    'tie': 'cmpSpeedTie',
  }[winner];
  return ' <span class="badge badge-speed speed-$winner">⚡ ${chrome[key]}</span>';
}

/// Function chips linking each operator to its 101 tutorial. Every name in
/// `functions:` must have a tutorial page — a missing one is a build error
/// rather than a 404 shipped to readers.
String _cmpChips(Page page) {
  final b = StringBuffer('<ul class="fn-list cmp-fns">');
  for (final raw in page.get('functions').split(',')) {
    final fn = raw.trim();
    if (fn.isEmpty) continue;
    if (!File('$root/content/tutorials/$fn.md').existsSync()) {
      throw StateError('${page.get('slug')}: functions lists `$fn` '
          'but content/tutorials/$fn.md does not exist');
    }
    b.write('<li><a href="../tutorials/$fn.html">$fn</a></li>');
  }
  b.write('</ul>');
  return b.toString();
}

/// Links bare `<code>name</code>` (or `<code>name()</code>`) prose mentions
/// to the function's 101 tutorial — but only for names in [allowed]: the
/// example's `functions:` list plus its optional `alsoLink:` extras. Prose
/// also name-drops *native* Dart functions (`fold`, `reduce`, `sort`…) that
/// share fxdart vocabulary; those must stay plain, which is why matching is
/// whitelist-based rather than "a tutorial exists". Existing anchors pass
/// through untouched, so hand-written links are never double-wrapped.
String _autoLinkFunctions(String html, Set<String> allowed) {
  final anchorOrCode = RegExp(
      r'<a\b[^>]*>.*?</a>|<code>([A-Za-z][A-Za-z0-9]*)(\(\))?</code>',
      dotAll: true);
  return html.replaceAllMapped(anchorOrCode, (m) {
    final fn = m.group(1);
    if (fn == null) return m.group(0)!; // an existing anchor — leave it
    if (!allowed.contains(fn)) return m.group(0)!;
    final label = '$fn${m.group(2) ?? ''}';
    return '<code><a href="../tutorials/$fn.html">$label</a></code>';
  });
}

/// The prose-linkable function names for a comparison page: its chips plus
/// `alsoLink:` extras (genuine fxdart mentions outside the chip list). Every
/// name must have a tutorial — `alsoLink` typos would otherwise ship 404s.
Set<String> _linkableFunctions(Page page) {
  final names = {
    for (final f in page.get('functions').split(',')) f.trim(),
    for (final f in page.get('alsoLink').split(',')) f.trim(),
  }..remove('');
  for (final fn in names) {
    if (!File('$root/content/tutorials/$fn.md').existsSync()) {
      throw StateError('${page.get('slug')}: `$fn` (functions/alsoLink) has '
          'no tutorial at content/tutorials/$fn.md');
    }
  }
  return names;
}

/// Expands {{root}}, {{comparison}} (the side-by-side dual playground) and
/// {{output}} (the harness-verified expected output) for a comparison page.
/// Code and expected output live in `content/<codeDir>/<slug>/` and are
/// locale-invariant, like content/code/.
String _injectComparisonCode(String body, String slug, int depth,
    Map<String, String> chrome, _CmpFamily family) {
  final dir = '$root/content/${family.codeDir}/$slug';

  body = body.replaceAll('{{root}}', _rel(depth));

  body = body.replaceAll('{{comparison}}', () {
    String panel(String file, String chromeKey, String side) {
      final f = File('$dir/$file');
      if (!f.existsSync()) throw StateError('$slug: missing $file');
      final code = pg.snippetCode(f.readAsStringSync());
      return '''
    <section class="cmp-panel cmp-$side">
      <h3>${chrome[chromeKey]}</h3>
      <div class="playground"${_pgAttr(code)}>
<textarea>
$code
</textarea>
      </div>
    </section>''';
    }

    return '<div class="comparison">\n'
        '${panel(family.leftFile, family.leftKey, family.leftSide)}\n'
        '${panel('fxdart.dart', 'cmpFxdart', 'fxdart')}\n'
        '  </div>';
  }());

  return body.replaceAll('{{output}}', () {
    final f = File('$dir/expected.txt');
    if (!f.existsSync()) {
      throw StateError('$slug: missing expected.txt — run '
          '`dart run tool/check_comparison.dart${family.bench ? '' : ' --rx'}`');
    }
    final out = _escapeHtml(f.readAsStringSync().trimRight());
    return '<details class="cmp-expected">\n'
        '    <summary>${chrome['cmpExpected']}</summary>\n'
        '    <pre class="code">$out</pre>\n'
        '  </details>';
  }());
}

// --- benchmark section ------------------------------------------------------
//
// benchmark/results/results.json is produced by `dart run
// benchmark/run_benchmarks.dart` (see benchmark/README.md). When present, each
// comparison page gets a Benchmark section with time and peak-memory bars; when
// absent (or a case failed), the section is simply omitted and the build still
// succeeds.

final _benchCache = <String, Map<String, dynamic>?>{};

Map<String, dynamic>? _benchResults(String file) =>
    _benchCache.putIfAbsent(file, () {
      final f = File('$root/benchmark/results/$file');
      if (!f.existsSync()) return null;
      return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    });

String _benchFmtInt(num n) {
  final s = n.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

String _benchFmtUs(num us) {
  if (us < 1) return '${(us * 1000).toStringAsFixed(0)} ns';
  if (us < 1000) return '${us.toStringAsFixed(us < 10 ? 1 : 0)} µs';
  return '${(us / 1000).toStringAsFixed(us < 10000 ? 2 : 1)} ms';
}

String _benchFmtMb(num bytes) =>
    '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

String _cmpBenchSection(String slug, Map<String, String> chrome,
    _CmpFamily family,
    {bool isAsync = false, String? noBenchmark}) {
  // Some examples cannot be benchmarked honestly — see the `noBenchmark:`
  // front-matter key. Say so where the bars would be, so a deliberate
  // exclusion does not read as a case someone forgot to measure.
  if (noBenchmark != null && noBenchmark.isNotEmpty) {
    final key = 'cmpBenchNone'
        '${noBenchmark[0].toUpperCase()}${noBenchmark.substring(1)}';
    final text = chrome[key];
    if (text == null) {
      throw StateError('$slug: unknown `noBenchmark: $noBenchmark` '
          '(no chrome key "$key")');
    }
    return (StringBuffer()
          ..writeln('  <section class="cmp-bench">')
          ..writeln('  <h2>${chrome['cmpBenchTitle']}</h2>')
          ..writeln('  <p class="dim bench-note bench-none">$text</p>')
          ..writeln('  </section>'))
        .toString();
  }
  final data = _benchResults(family.benchResults);
  if (data == null) return '';
  final winKeys = {
    family.leftSide: family.benchWinLeftKey,
    'fxdart': 'cmpBenchWinFxdart',
    'tie': 'cmpBenchWinTie',
  };
  final c = (data['cases'] as Map<String, dynamic>)[slug] as Map<String, dynamic>?;
  final scales = c?['scales'] as Map<String, dynamic>?;
  if (scales == null) return '';
  final machine = data['machine'] as Map<String, dynamic>;

  // A case may publish a second FxDart spelling (benchmark/cases/<slug>/
  // fxdart_strict.dart) when the gap between two ways of writing the same
  // pipeline is the point the page makes. It is a third bar only — the
  // verdict badge stays a two-way call.
  String metric(String titleKey, String winner, num natVal, num fxVal,
      num? strictVal, String Function(num) fmt) {
    var max = natVal > fxVal ? natVal : fxVal;
    if (strictVal != null && strictVal > max) max = strictVal;
    String row(String nameKey, String side, num v) {
      final pct = (v / max * 100).toStringAsFixed(1);
      return '''
      <div class="bench-row">
        <span class="bench-name">${chrome[nameKey]}</span>
        <span class="bench-track"><span class="bench-bar bench-$side" style="width:$pct%"></span></span>
        <span class="bench-val">${fmt(v)}</span>
      </div>''';
    }

    final strictRow = strictVal == null
        ? ''
        : '\n${row('cmpFxdartStrict', 'fxdart-strict', strictVal)}';
    return '''
    <div class="bench-metric">
      <h4>${chrome[titleKey]} <span class="badge verdict-$winner">${chrome[winKeys[winner]]}</span></h4>
${row(family.leftKey, family.leftSide, natVal)}
${row('cmpFxdart', 'fxdart', fxVal)}$strictRow
    </div>''';
  }

  final blocks = StringBuffer();
  for (final scale in family.benchScales) {
    final s = scales[scale] as Map<String, dynamic>?;
    if (s == null || s.containsKey('error')) continue;
    final nat = s[family.leftSide] as Map<String, dynamic>;
    final fx = s['fxdart'] as Map<String, dynamic>;
    final strict = s['fxdart_strict'] as Map<String, dynamic>?;
    final heading = chrome['cmpBenchScale']!
        .replaceAll('{n}', _benchFmtInt(s['n'] as num));
    blocks
      ..writeln('  <div class="bench-scale">')
      ..writeln('    <h3>$heading</h3>')
      ..writeln(metric('cmpBenchTime', s['timeWinner'] as String,
          nat['medianUs'] as num, fx['medianUs'] as num,
          strict?['medianUs'] as num?, _benchFmtUs))
      ..writeln(metric('cmpBenchMemory', s['memWinner'] as String,
          nat['medianRssBytes'] as num, fx['medianRssBytes'] as num,
          strict?['medianRssBytes'] as num?, _benchFmtMb))
      ..writeln('  </div>');
  }
  if (blocks.isEmpty) return '';

  final meta = chrome['cmpBenchMeta']!
      .replaceAll('{cpu}', '${machine['cpu']}')
      .replaceAll('{ram}', '${machine['ramGb']}')
      .replaceAll('{dart}', '${machine['dart']}')
      .replaceAll('{date}', '${data['date']}');
  final absMs = (data['tieAbsMs'] ?? 5) as num;
  final methodNote = chrome['cmpBenchMethodNote']!
      .replaceAll('{margin}', '${(data['tieMarginPct'] as num).round()}')
      .replaceAll(
          '{absMs}', absMs == absMs.round() ? '${absMs.round()}' : '$absMs');

  // Async cases cap their headline N (every element costs an event-loop turn
  // on both sides); say so on the page rather than leaving the smaller N to
  // look like an arbitrary choice.
  var asyncNote = '';
  if (isAsync) {
    final full = scales['full'] as Map<String, dynamic>?;
    final headlineN = (full?['n'] ??
        (scales.values.whereType<Map<String, dynamic>>().toList()
              ..sort((a, b) => (a['n'] as num).compareTo(b['n'] as num)))
            .last['n']) as num;
    asyncNote = '  <p class="dim bench-note bench-async-note">'
        '${chrome['cmpBenchAsyncNote']!.replaceAll('{n}', _benchFmtInt(headlineN))}'
        '</p>\n';
  }

  return (StringBuffer()
        ..writeln('  <section class="cmp-bench">')
        ..writeln('  <h2>${chrome['cmpBenchTitle']}</h2>')
        ..writeln('  <p class="dim bench-meta">$meta</p>')
        ..write(asyncNote)
        ..writeln('  <div class="bench-scales">')
        ..write(blocks)
        ..writeln('  </div>')
        ..writeln('  <p class="dim bench-note">$methodNote '
            '${chrome['cmpBenchMemNote']}</p>')
        ..writeln('  </section>'))
      .toString();
}

// --- the parallel benchmark page --------------------------------------------

/// One CPU-bound job, five ways to run it, measured.
///
/// Not a `_CmpFamily`: that machinery pairs a left side against fxdart and
/// prints a verdict between them. Here there are five sides and the answer
/// is a *shape* rather than a winner — "heavy work wins without tuning",
/// "cheap work needs a chunk" — which a two-way verdict would flatten.
///
/// Every label and number comes from `benchmark/results/results-parallel.json`,
/// so the page carries no measurement of its own: regenerate with
/// `dart run benchmark/run_parallel_benchmarks.dart` and it re-renders.
String _renderParallelBench(
  Locale locale,
  List<Locale> locales,
  Map<String, String> chrome,
  Page page,
) {
  const path = 'parallel-benchmark.html';
  final depth = locale.depth;
  final b = StringBuffer()
    ..write(_head(locale, locales, page, path, depth, playground: false))
    ..write(_header(locale, locales, chrome, path, depth, 'compare'))
    ..writeln('<main class="page cmp-page pbench-page">')
    ..writeln('  <h1>${page.get('heading', page.get('title'))}</h1>');
  if (!page.translated) {
    b.writeln('  <p class="dim">${chrome['notTranslated'] ?? ''}</p>');
  }
  b
    ..write(page.body)
    ..write(_parallelBenchSection(chrome))
    ..writeln('</main>')
    ..write(_footer(chrome))
    ..writeln('</body>')
    ..writeln('</html>');
  return b.toString();
}

/// The measured half of the page: one block per case, five bars per scale,
/// and the five programs that produced them.
String _parallelBenchSection(Map<String, String> chrome) {
  final f = File('$root/benchmark/results/results-parallel.json');
  if (!f.existsSync()) return '';
  final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  final impls = (data['impls'] as List).cast<String>();
  final jsonLabels = (data['labels'] as Map).cast<String, dynamic>();
  final labels = <String, String>{
    for (final i in impls)
      i: chrome[_pbenchLabelKey[i]] ?? (jsonLabels[i] as String? ?? i),
  };
  final workers = data['workers'];
  final meta = (chrome['pbenchMeta'] ?? '')
      .replaceAll('{workers}', '$workers')
      .replaceAll('{rounds}', '${data['rounds']}')
      .replaceAll('{count}', '${impls.length}');

  final out = StringBuffer()
    ..writeln('  <section class="cmp-bench pbench">')
    ..writeln('  <p class="dim bench-meta">$meta</p>');

  for (final c in (data['cases'] as List).cast<Map<String, dynamic>>()) {
    final slug = c['slug'] as String;
    final scales = (c['scales'] as Map).cast<String, dynamic>();
    out
      ..writeln('  <div class="pbench-case">')
      ..writeln('    <h2 id="$slug"><code>$slug</code></h2>');
    for (final scaleKey in const ['full', '10000', '100']) {
      final s = scales[scaleKey] as Map<String, dynamic>?;
      if (s == null) continue;
      final ms = (s['ms'] as Map).cast<String, dynamic>();
      final speedup = (s['speedupVsNative'] as Map).cast<String, dynamic>();
      var max = 0.0;
      for (final i in impls) {
        final v = (ms[i] as num).toDouble();
        if (v > max) max = v;
      }
      out
        ..writeln('    <div class="bench-scale">')
        ..writeln('      <h3>N = ${_benchFmtInt(s['n'] as num)}</h3>');
      for (final i in impls) {
        final v = (ms[i] as num).toDouble();
        final up = (speedup[i] as num).toDouble();
        // Read against the plain loop, because that is the only baseline a
        // reader deciding "should I bother with isolates" actually has.
        final note = i == 'native'
            ? chrome['pbenchNoteBaseline']!
            : up >= 1.005
            ? chrome['pbenchNoteFaster']!
                .replaceAll('{n}', up.toStringAsFixed(2))
            : up <= 0.995
            ? chrome['pbenchNoteSlower']!
                .replaceAll('{n}', (1 / up).toStringAsFixed(2))
            : chrome['pbenchNoteSame']!;
        final cls = i == 'native'
            ? 'base'
            : up >= 1.005
            ? 'win'
            : up <= 0.995
            ? 'loss'
            : 'tie';
        final pct = (v / max * 100).toStringAsFixed(1);
        out
          ..writeln('      <div class="bench-row">')
          ..writeln('        <span class="bench-name">${labels[i]}</span>')
          ..writeln(
            '        <span class="bench-track">'
            '<span class="bench-bar pbench-$cls" style="width:$pct%"></span>'
            '</span>',
          )
          ..writeln(
            '        <span class="bench-val">${_pbenchMs(v)} '
            '<em class="pbench-note pbench-$cls">$note</em></span>',
          )
          ..writeln('      </div>');
      }
      out.writeln('    </div>');
    }
    out
      ..write(_parallelBenchCode(chrome, slug, impls, labels))
      ..writeln('  </div>');
  }
  out.writeln('  </section>');
  return out.toString();
}

/// The five programs, read straight off disk — so what the page shows is what
/// was compiled and timed, and cannot drift from it.
String _parallelBenchCode(
  Map<String, String> chrome,
  String slug,
  List<String> impls,
  Map<String, String> labels,
) {
  const files = {
    'native': 'native',
    'native-isolate': 'native_isolate',
    'fxdart': 'fxdart',
    'fxdart-parallel': 'fxdart_parallel',
    'fxdart-parallel-chunk': 'fxdart_parallel_chunk',
  };
  final out = StringBuffer()
    ..writeln('    <details class="pbench-code">')
    ..writeln('      <summary>${chrome['pbenchCodeSummary']}</summary>');
  final work = File('$root/benchmark/cases-parallel/$slug/work.dart');
  if (work.existsSync()) {
    out
      ..writeln('      <figure class="pbench-work">')
      ..writeln('        <figcaption>${chrome['pbenchCodeJob']}</figcaption>')
      ..writeln(
        '        <pre><code>'
        '${_escapeHtml(work.readAsStringSync().trimRight())}</code></pre>',
      )
      ..writeln('      </figure>');
  }
  out.writeln('      <div class="pbench-grid">');
  for (final i in impls) {
    final src = File('$root/benchmark/cases-parallel/$slug/${files[i]}.dart');
    if (!src.existsSync()) continue;
    out
      ..writeln('        <figure>')
      ..writeln('          <figcaption>${labels[i]}</figcaption>')
      ..writeln(
        '          <pre><code>'
        '${_escapeHtml(src.readAsStringSync().trimRight())}</code></pre>',
      )
      ..writeln('        </figure>');
  }
  out
    ..writeln('      </div>')
    ..writeln('    </details>');
  return out.toString();
}

String _pbenchMs(double ms) => ms >= 1000
    ? '${(ms / 1000).toStringAsFixed(2)} s'
    : '${ms.toStringAsFixed(1)} ms';

const _pbenchLabelKey = {
  'native': 'pbenchLabelNative',
  'native-isolate': 'pbenchLabelNativeIsolate',
  'fxdart': 'pbenchLabelFxdart',
  'fxdart-parallel': 'pbenchLabelParallel',
  'fxdart-parallel-chunk': 'pbenchLabelParallelChunk',
};

String _renderComparisonIndex(
  Locale locale,
  List<Locale> locales,
  Map<String, String> chrome,
  Page page,
  List<Page> examples,
  _CmpFamily family,
) {
  final depth = locale.depth + 1;
  final indexPath = '${family.outDir}/index.html';
  final b = StringBuffer()
    ..write(_head(locale, locales, page, indexPath, depth, playground: false))
    ..write(_header(
        locale, locales, chrome, indexPath, depth, family.navActive))
    ..writeln('<main>')
    ..write(_banner(chrome, page))
    // The TOC intro mixes fxdart vocabulary with native mentions (`where`,
    // `map`); its links are hand-written in the markdown, not auto-added.
    ..writeln(page.body.replaceAll('{{root}}', _rel(depth)));

  // The two-standpoint legend: the markdown intro explains the filled code
  // verdicts; this line introduces the outlined measured-speed badge beside
  // them. Only rendered when the family carries benchmark results at all.
  if (family.bench && _benchResults(family.benchResults) != null) {
    b.writeln('  <p class="dim cmp-speed-legend">${chrome['cmpSpeedLegend']}</p>');
  }

  final picks = [
    for (final n in family.picks)
      for (final e in examples)
        if (e.get('order') == '$n') e,
  ];
  if (picks.isNotEmpty) {
    b
      ..writeln('')
      ..writeln('  <p class="cmp-picks"><span>${chrome['cmpPicks']}</span>');
    b.writeln(picks
        .map((e) =>
            '    <a href="${e.get('slug')}.html">#${e.get('order')} ${e.get('heading')}</a>')
        .join(' ·\n'));
    b.writeln('  </p>');
  }

  // Hidden until js/comparison.js wires it up — no JS, no broken UI.
  b
    ..writeln('')
    ..writeln('  <div class="cmp-filter" hidden>')
    ..writeln('    <button data-filter="all" class="active">'
        '${chrome['cmpFilterAll']}</button>')
    ..writeln('    <button data-filter="async">${chrome['cmpAsyncBadge']}</button>');
  // A verdict no example carries would render a filter button that can
  // only ever empty the list — omit it.
  final present = {for (final e in examples) e.get('verdict')};
  for (final e in family.verdictKeys.entries) {
    if (!present.contains(e.key)) continue;
    b.writeln('    <button data-filter="${e.key}">${chrome[e.value]}</button>');
  }
  b
    ..writeln('    <input type="search" placeholder="${chrome['cmpFilterFn']}">')
    ..writeln('  </div>');

  for (var tier = 1; tier <= 4; tier++) {
    final rows = examples.where((e) => e.get('tier') == '$tier').toList();
    if (rows.isEmpty) continue;
    b
      ..writeln('')
      ..writeln('  <section class="cmp-tier">')
      ..writeln('  <h2>${chrome['${family.tierPrefix}$tier']}</h2>')
      ..writeln('  <p class="dim">${chrome['${family.tierPrefix}${tier}Blurb']}</p>')
      ..writeln('  <ol class="cmp-list">');
    for (final e in rows) {
      final fns = e
          .get('functions')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .join(' ');
      final speed = _cmpSpeedWinner(family, e.get('slug'));
      b
        ..writeln('    <li data-verdict="${e.get('verdict')}" '
            'data-async="${e.get('async')}" data-speed="${speed ?? ''}" '
            'data-fns="$fns">')
        ..writeln('      <a class="cmp-row" href="${e.get('slug')}.html">')
        ..writeln('        <span class="cmp-num">${e.get('order')}</span>')
        ..writeln('        <span class="cmp-row-body">')
        ..writeln('          <strong>${e.get('heading')}</strong> '
            '${_cmpBadges(chrome, e, family)}'
            '${_cmpSpeedBadge(chrome, family, e.get('slug'))}')
        ..writeln('          <span class="dim">${e.get('description')}</span>')
        ..writeln('        </span>')
        ..writeln('      </a>')
        ..writeln('      ${_cmpChips(e)}')
        ..writeln('    </li>');
    }
    b
      ..writeln('  </ol>')
      ..writeln('  </section>');
  }

  b
    ..writeln('</main>')
    ..write(_footer(chrome))
    ..writeln('<script src="${_rel(depth)}js/comparison.js" defer></script>')
    ..writeln('</body>')
    ..writeln('</html>');
  return b.toString();
}

String _renderComparison(
  Locale locale,
  List<Locale> locales,
  Map<String, String> chrome,
  Page page,
  _CmpFamily family, {
  Page? prev,
  Page? next,
}) {
  final depth = locale.depth + 1;
  final slug = page.get('slug');
  final path = '${family.outDir}/$slug.html';
  final p = _rel(depth);

  final b = StringBuffer()
    ..write(_head(locale, locales, page, path, depth))
    ..write(_header(locale, locales, chrome, path, depth, family.navActive))
    // Two editors side by side need more room than the prose column.
    ..writeln('<main class="cmp-wide">')
    ..write(_banner(chrome, page))
    ..writeln('  <p class="breadcrumb">'
        '<a href="$p${family.outDir}/index.html">${chrome[family.crumbKey]}</a> › '
        '#${page.get('order')} · <strong>${page.get('heading')}</strong></p>')
    ..writeln('  <h1>${page.get('heading')}</h1>')
    ..writeln('  <p class="cmp-meta">${_cmpBadges(chrome, page, family)}</p>')
    ..writeln('  ${_cmpChips(page)}')
    // Auto-link before code injection so the regex only ever sees prose,
    // never the playground code blocks.
    ..writeln(_injectComparisonCode(
        _autoLinkFunctions(page.body, _linkableFunctions(page)),
        slug,
        depth,
        chrome,
        family));
  if (family.bench) {
    b.write(_cmpBenchSection(slug, chrome, family,
        isAsync: page.get('async') == 'true',
        noBenchmark: page.get('noBenchmark')));
  }
  b
    ..writeln('')
    ..writeln('  <nav class="tut-nav">');
  if (prev != null) {
    b.writeln('    <a href="${prev.get('slug')}.html">'
        '← ${chrome['prevPrefix']}${prev.get('heading')}</a>');
  } else {
    b.writeln(
        '    <a href="$p${family.outDir}/index.html">← ${chrome[family.crumbKey]}</a>');
  }
  if (next != null) {
    b.writeln('    <a href="${next.get('slug')}.html">'
        '${chrome['nextPrefix']}${next.get('heading')} →</a>');
  }
  b
    ..writeln('  </nav>')
    ..writeln('</main>')
    ..write(_footer(chrome))
    ..write(_scripts(locale, chrome, depth));
  return b.toString();
}

// --- sitemap ----------------------------------------------------------------

class _PageRef {
  _PageRef(this.locale, this.path, this.translated);
  final Locale locale;
  final String path;
  final bool translated;
}

String _renderSitemap(List<_PageRef> pages, List<Locale> locales) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"'
        ' xmlns:xhtml="http://www.w3.org/1999/xhtml">');
  // Untranslated pages are canonicalised to English, so listing them would
  // advertise URLs we are asking search engines to ignore.
  for (final page in pages.where((p) => p.translated)) {
    b
      ..writeln('  <url>')
      ..writeln('    <loc>${_url(page.locale, page.path)}</loc>');
    for (final l in locales) {
      b.writeln('    <xhtml:link rel="alternate" hreflang="${l.code}"'
          ' href="${_url(l, page.path)}"/>');
    }
    b.writeln('  </url>');
  }
  b.writeln('</urlset>');
  return b.toString();
}
