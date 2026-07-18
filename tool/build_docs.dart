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

const siteBase = 'https://bansooknam.github.io/FxDart';
const codemirror = 'https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16';
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
      for (final f in _tutorialFiles()) 'tutorials/${f.split('/').last}',
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

    // Only `title` and `description` are prose. Everything else is structure —
    // function names and link targets — and a translated `next:` would quietly
    // break the tutorial chain for that language only.
    final enMeta = _frontMatter(english);
    for (final key in enMeta.keys.toList()..addAll(meta.keys)) {
      if (key == 'title' || key == 'description') continue;
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

final _placeholders = RegExp(r'\{\{(?:root|signature|playground:\d+)\}\}');

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
    final code = f.readAsStringSync().trimRight();
    return '<div class="playground">\n<textarea>\n$code\n</textarea>\n  </div>';
  });
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
<script>window.FXDART_I18N = ${jsonEncode(map)};</script>
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
