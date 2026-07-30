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

    // Dart vs FxDart comparison.
    final cmpIndex = _loadPage('pages/comparison.md', locale);
    final cmpPages = [
      for (final file in _comparisonFiles())
        _loadPage('comparison/${file.split('/').last}', locale),
    ]..sort((a, b) =>
        int.parse(a.get('order')).compareTo(int.parse(b.get('order'))));
    written[_out(locale, 'DartComparison/index.html')] =
        _renderComparisonIndex(locale, locales, chrome, cmpIndex, cmpPages);
    pages.add(
        _PageRef(locale, 'DartComparison/index.html', cmpIndex.translated));
    for (var i = 0; i < cmpPages.length; i++) {
      final page = cmpPages[i];
      final path = 'DartComparison/${page.get('slug')}.html';
      written[_out(locale, path)] = _renderComparison(
          locale, locales, chrome, page,
          prev: i > 0 ? cmpPages[i - 1] : null,
          next: i < cmpPages.length - 1 ? cmpPages[i + 1] : null);
      pages.add(_PageRef(locale, path, page.translated));
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

  written.forEach((path, content) {
    final f = File('$root/$path');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(content);
  });

  final translated = pages.where((p) => p.translated).length;
  stdout.writeln('built ${written.length} files across ${locales.length} locales');
  stdout.writeln('$translated/${pages.length} pages translated');
}

// --- translation bookkeeping ------------------------------------------------

/// Every content file that can be translated, as a path relative to content/.
List<String> _translatable() => [
      'pages/index.md',
      'pages/101.md',
      'pages/comparison.md',
      for (final f in _tutorialFiles()) 'tutorials/${f.split('/').last}',
      for (final f in _comparisonFiles()) 'comparison/${f.split('/').last}',
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

List<String> _comparisonFiles() => (Directory('$root/content/comparison')
        .listSync()
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('.md'))
        .toList()
      ..sort());

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
      <a href="${p}DartComparison/index.html"${cls('compare')}>${chrome['navCompare']}</a>
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

// --- Dart vs FxDart comparison ----------------------------------------------

const _verdictKeys = {
  'fxdart': 'cmpVerdictFxdart',
  'tie': 'cmpVerdictTie',
  'native': 'cmpVerdictNative',
};

String _escapeHtml(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// The verdict badge (and, for async examples, the async badge). The verdict
/// is structure, not prose — an unknown value is a typo, not a new category.
String _cmpBadges(Map<String, String> chrome, Page page) {
  final verdict = page.get('verdict');
  final key = _verdictKeys[verdict];
  if (key == null) {
    throw StateError('${page.get('slug')}: unknown verdict `$verdict` '
        '(expected one of: ${_verdictKeys.keys.join(', ')})');
  }
  final b = StringBuffer(
      '<span class="badge verdict-$verdict">${chrome[key]}</span>');
  if (page.get('async') == 'true') {
    b.write(' <span class="badge badge-async">${chrome['cmpAsyncBadge']}</span>');
  }
  return b.toString();
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
/// Code and expected output live in `content/code-comparison/<slug>/` and are
/// locale-invariant, like content/code/.
String _injectComparisonCode(
    String body, String slug, int depth, Map<String, String> chrome) {
  final dir = '$root/content/code-comparison/$slug';

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
        '${panel('native.dart', 'cmpNative', 'native')}\n'
        '${panel('fxdart.dart', 'cmpFxdart', 'fxdart')}\n'
        '  </div>';
  }());

  return body.replaceAll('{{output}}', () {
    final f = File('$dir/expected.txt');
    if (!f.existsSync()) {
      throw StateError(
          '$slug: missing expected.txt — run `dart run tool/check_comparison.dart`');
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

Map<String, dynamic>? _benchCache;
bool _benchLoaded = false;

Map<String, dynamic>? get _benchResults {
  if (!_benchLoaded) {
    _benchLoaded = true;
    final f = File('$root/benchmark/results/results.json');
    if (f.existsSync()) {
      _benchCache = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    }
  }
  return _benchCache;
}

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

const _benchWinKeys = {
  'native': 'cmpBenchWinNative',
  'fxdart': 'cmpBenchWinFxdart',
  'tie': 'cmpBenchWinTie',
};

/// Scale-block order: small → large, `full` = the case's headline N.
const _benchScaleOrder = ['100', '10000', 'full'];

String _cmpBenchSection(String slug, Map<String, String> chrome) {
  final data = _benchResults;
  if (data == null) return '';
  final c = (data['cases'] as Map<String, dynamic>)[slug] as Map<String, dynamic>?;
  final scales = c?['scales'] as Map<String, dynamic>?;
  if (scales == null) return '';
  final machine = data['machine'] as Map<String, dynamic>;

  String metric(String titleKey, String winner, num natVal, num fxVal,
      String Function(num) fmt) {
    final max = natVal > fxVal ? natVal : fxVal;
    String row(String nameKey, String side, num v) {
      final pct = (v / max * 100).toStringAsFixed(1);
      return '''
      <div class="bench-row">
        <span class="bench-name">${chrome[nameKey]}</span>
        <span class="bench-track"><span class="bench-bar bench-$side" style="width:$pct%"></span></span>
        <span class="bench-val">${fmt(v)}</span>
      </div>''';
    }

    return '''
    <div class="bench-metric">
      <h4>${chrome[titleKey]} <span class="badge verdict-$winner">${chrome[_benchWinKeys[winner]]}</span></h4>
${row('cmpNative', 'native', natVal)}
${row('cmpFxdart', 'fxdart', fxVal)}
    </div>''';
  }

  final blocks = StringBuffer();
  for (final scale in _benchScaleOrder) {
    final s = scales[scale] as Map<String, dynamic>?;
    if (s == null || s.containsKey('error')) continue;
    final nat = s['native'] as Map<String, dynamic>;
    final fx = s['fxdart'] as Map<String, dynamic>;
    final heading = chrome['cmpBenchScale']!
        .replaceAll('{n}', _benchFmtInt(s['n'] as num));
    blocks
      ..writeln('  <div class="bench-scale">')
      ..writeln('    <h3>$heading</h3>')
      ..writeln(metric('cmpBenchTime', s['timeWinner'] as String,
          nat['medianUs'] as num, fx['medianUs'] as num, _benchFmtUs))
      ..writeln(metric('cmpBenchMemory', s['memWinner'] as String,
          nat['medianRssBytes'] as num, fx['medianRssBytes'] as num,
          _benchFmtMb))
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

  return (StringBuffer()
        ..writeln('  <section class="cmp-bench">')
        ..writeln('  <h2>${chrome['cmpBenchTitle']}</h2>')
        ..writeln('  <p class="dim bench-meta">$meta</p>')
        ..writeln('  <div class="bench-scales">')
        ..write(blocks)
        ..writeln('  </div>')
        ..writeln('  <p class="dim bench-note">$methodNote '
            '${chrome['cmpBenchMemNote']}</p>')
        ..writeln('  </section>'))
      .toString();
}

/// The orders of the five examples the TOC recommends to a reader in a hurry.
const _cmpPicks = [1, 11, 30, 41, 50];

String _renderComparisonIndex(
  Locale locale,
  List<Locale> locales,
  Map<String, String> chrome,
  Page page,
  List<Page> examples,
) {
  final depth = locale.depth + 1;
  final b = StringBuffer()
    ..write(_head(locale, locales, page, 'DartComparison/index.html', depth,
        playground: false))
    ..write(_header(
        locale, locales, chrome, 'DartComparison/index.html', depth, 'compare'))
    ..writeln('<main>')
    ..write(_banner(chrome, page))
    // The TOC intro mixes fxdart vocabulary with native mentions (`where`,
    // `map`); its links are hand-written in the markdown, not auto-added.
    ..writeln(page.body.replaceAll('{{root}}', _rel(depth)));

  final picks = [
    for (final n in _cmpPicks)
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
    ..writeln('    <button data-filter="async">${chrome['cmpAsyncBadge']}</button>')
    ..writeln('    <button data-filter="fxdart">${chrome['cmpVerdictFxdart']}</button>')
    ..writeln('    <button data-filter="tie">${chrome['cmpVerdictTie']}</button>')
    ..writeln('    <button data-filter="native">${chrome['cmpVerdictNative']}</button>')
    ..writeln('    <input type="search" placeholder="${chrome['cmpFilterFn']}">')
    ..writeln('  </div>');

  for (var tier = 1; tier <= 4; tier++) {
    final rows = examples.where((e) => e.get('tier') == '$tier').toList();
    if (rows.isEmpty) continue;
    b
      ..writeln('')
      ..writeln('  <section class="cmp-tier">')
      ..writeln('  <h2>${chrome['cmpTier$tier']}</h2>')
      ..writeln('  <p class="dim">${chrome['cmpTier${tier}Blurb']}</p>')
      ..writeln('  <ol class="cmp-list">');
    for (final e in rows) {
      final fns = e
          .get('functions')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .join(' ');
      b
        ..writeln('    <li data-verdict="${e.get('verdict')}" '
            'data-async="${e.get('async')}" data-fns="$fns">')
        ..writeln('      <a class="cmp-row" href="${e.get('slug')}.html">')
        ..writeln('        <span class="cmp-num">${e.get('order')}</span>')
        ..writeln('        <span class="cmp-row-body">')
        ..writeln('          <strong>${e.get('heading')}</strong> '
            '${_cmpBadges(chrome, e)}')
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
  Page page, {
  Page? prev,
  Page? next,
}) {
  final depth = locale.depth + 1;
  final slug = page.get('slug');
  final path = 'DartComparison/$slug.html';
  final p = _rel(depth);

  final b = StringBuffer()
    ..write(_head(locale, locales, page, path, depth))
    ..write(_header(locale, locales, chrome, path, depth, 'compare'))
    // Two editors side by side need more room than the prose column.
    ..writeln('<main class="cmp-wide">')
    ..write(_banner(chrome, page))
    ..writeln('  <p class="breadcrumb">'
        '<a href="${p}DartComparison/index.html">${chrome['crumbCompare']}</a> › '
        '#${page.get('order')} · <strong>${page.get('heading')}</strong></p>')
    ..writeln('  <h1>${page.get('heading')}</h1>')
    ..writeln('  <p class="cmp-meta">${_cmpBadges(chrome, page)}</p>')
    ..writeln('  ${_cmpChips(page)}')
    // Auto-link before code injection so the regex only ever sees prose,
    // never the playground code blocks.
    ..writeln(_injectComparisonCode(
        _autoLinkFunctions(page.body, _linkableFunctions(page)),
        slug,
        depth,
        chrome))
    ..write(_cmpBenchSection(slug, chrome))
    ..writeln('')
    ..writeln('  <nav class="tut-nav">');
  if (prev != null) {
    b.writeln('    <a href="${prev.get('slug')}.html">'
        '← ${chrome['prevPrefix']}${prev.get('heading')}</a>');
  } else {
    b.writeln(
        '    <a href="${p}DartComparison/index.html">← ${chrome['crumbCompare']}</a>');
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
