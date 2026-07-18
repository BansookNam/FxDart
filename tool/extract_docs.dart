// One-time migration: turn the hand-written docs/ HTML into the content/ source
// tree that tool/build_docs.dart renders from.
//
// The split is the whole point of the exercise:
//
//   content/tutorials/<fn>.md   translatable prose + front matter
//   content/code/<fn>/*.dart    playground code — shared by every locale
//   content/code/<fn>/sig.txt   type signature — shared by every locale
//
// Code is never duplicated per locale, so a Korean reader and an English reader
// always run byte-identical Dart, and a library change updates one file rather
// than seven.
//
// Rerunnable: always regenerates content/ from scratch. Safe to delete content/
// and re-run as long as docs/ is still the pre-migration HTML (use git).

import 'dart:io';

final _root = Directory.current;

// --- element patterns -------------------------------------------------------
// Every one of the 113 tutorial pages was verified to match these exactly
// before this script was written; a miss is a hard error rather than a skip.

final _title = RegExp(r'<title>(.*?)</title>', dotAll: true);
final _desc = RegExp(r'<meta name="description" content="(.*?)">', dotAll: true);
final _main = RegExp(r'<main>\n(.*?)\n</main>', dotAll: true);
final _breadcrumb = RegExp(r'  <p class="breadcrumb">(.*?)</p>\n', dotAll: true);
final _h1 = RegExp(r'  <h1>(.*?)</h1>\n', dotAll: true);
final _signature = RegExp(r'  <div class="signature">(.*?)</div>\n', dotAll: true);
final _playground = RegExp(
  r'  <div class="playground">\n<textarea>\n(.*?)\n</textarea>\n  </div>\n',
  dotAll: true,
);
final _tutNav = RegExp(r'\n  <nav class="tut-nav">\n(.*?)\n  </nav>', dotAll: true);
final _navLink = RegExp(r'<a href="([^"]*)">(.*?)</a>', dotAll: true);

// Breadcrumb: `<a href="../101/index.html">FxDart 101</a> › Section 3 · Transforming › <strong>map</strong>`
final _crumbParts = RegExp(r'</a> › Section (\d+) · (.*?) › <strong>(.*?)</strong>', dotAll: true);

void main() {
  final tutorials = Directory('${_root.path}/docs/tutorials')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.html'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (tutorials.isEmpty) {
    stderr.writeln('no tutorials found — is docs/ still the pre-migration HTML?');
    exit(1);
  }

  final sections = <int, String>{};
  var extracted = 0;

  for (final file in tutorials) {
    final slug = file.uri.pathSegments.last.replaceAll('.html', '');
    final html = file.readAsStringSync();
    final page = _extractTutorial(slug, html);
    sections[page.sectionNumber] = page.sectionTitle;
    _writeTutorial(page);
    extracted++;
  }

  _writeSections(sections);
  _extractLanding();
  final fns = _extractCourse();

  stdout.writeln('extracted $extracted tutorials + landing page');
  stdout.writeln('sections: ${sections.length}, course entries: $fns');
}

// --- tutorial extraction ----------------------------------------------------

class _Tutorial {
  _Tutorial({
    required this.slug,
    required this.title,
    required this.description,
    required this.heading,
    required this.sectionNumber,
    required this.sectionTitle,
    required this.crumbLabel,
    required this.prevHref,
    required this.prevLabel,
    required this.nextHref,
    required this.nextLabel,
    required this.signature,
    required this.code,
    required this.body,
  });

  final String slug;
  final String title;
  final String description;
  final String heading;
  final int sectionNumber;
  final String sectionTitle;
  final String crumbLabel;
  final String? prevHref;
  final String? prevLabel;
  final String? nextHref;
  final String? nextLabel;
  final String signature;
  final List<String> code;
  final String body;
}

_Tutorial _extractTutorial(String slug, String html) {
  String need(RegExp re, String what) {
    final m = re.firstMatch(html);
    if (m == null) throw StateError('$slug: no $what');
    return m.group(1)!;
  }

  final title = need(_title, 'title');
  final description = need(_desc, 'description');
  var body = need(_main, '<main>');

  // Breadcrumb -> section metadata (regenerated per locale by the builder).
  final crumbMatch = _breadcrumb.firstMatch(body);
  if (crumbMatch == null) throw StateError('$slug: no breadcrumb');
  final crumb = _crumbParts.firstMatch(crumbMatch.group(1)!);
  if (crumb == null) throw StateError('$slug: unparseable breadcrumb');
  body = body.replaceFirst(crumbMatch.group(0)!, '');

  // <h1> -> front matter (it is the function name, never translated).
  final h1Match = _h1.firstMatch(body);
  if (h1Match == null) throw StateError('$slug: no <h1>');
  body = body.replaceFirst(h1Match.group(0)!, '');

  // Signature -> shared code file.
  final sigMatch = _signature.firstMatch(body);
  if (sigMatch == null) throw StateError('$slug: no signature');
  body = body.replaceFirst(sigMatch.group(0)!, '  {{signature}}\n');

  // tut-nav -> front matter. Direction comes from the arrow, not link order:
  // most pages lead with a previous link, a few with the back-to-course link.
  // The prev prefix was written three ways by hand ("← Previous: x", "← Prev: x",
  // bare "← x"); all three collapse to one chrome string on the way out.
  String? prevHref, prevLabel, nextHref, nextLabel;
  final navMatch = _tutNav.firstMatch(body);
  if (navMatch == null) throw StateError('$slug: no tut-nav');

  for (final link in _navLink.allMatches(navMatch.group(1)!)) {
    final href = link.group(1)!;
    final label = link.group(2)!.trim();

    if (label.endsWith('→')) {
      nextHref = href;
      nextLabel = label
          .replaceFirst(RegExp(r'^Next:\s*'), '')
          .replaceFirst(RegExp(r'\s*→$'), '')
          .trim();
    } else if (label.startsWith('←')) {
      // The back-to-course link is chrome; the builder regenerates it.
      if (href.contains('101/index.html')) continue;
      prevHref = href;
      prevLabel = label
          .replaceFirst('←', '')
          .replaceFirst(RegExp(r'^\s*(Previous|Prev):\s*'), '')
          .trim();
    } else {
      throw StateError('$slug: undirected tut-nav link "$label"');
    }
  }
  body = body.replaceFirst(navMatch.group(0)!, '');

  // Playgrounds -> shared code files.
  final code = <String>[];
  body = body.replaceAllMapped(_playground, (m) {
    code.add(m.group(1)!);
    return '  {{playground:${code.length - 1}}}\n';
  });

  return _Tutorial(
    slug: slug,
    title: title,
    description: description,
    heading: h1Match.group(1)!,
    sectionNumber: int.parse(crumb.group(1)!),
    sectionTitle: crumb.group(2)!,
    crumbLabel: crumb.group(3)!,
    prevHref: prevHref,
    prevLabel: prevLabel,
    nextHref: nextHref,
    nextLabel: nextLabel,
    signature: sigMatch.group(1)!,
    code: code,
    body: _trimBlankLines(body),
  );
}

void _writeTutorial(_Tutorial t) {
  final codeDir = Directory('${_root.path}/content/code/${t.slug}')
    ..createSync(recursive: true);
  File('${codeDir.path}/sig.txt').writeAsStringSync('${t.signature}\n');
  for (var i = 0; i < t.code.length; i++) {
    File('${codeDir.path}/$i.dart').writeAsStringSync('${t.code[i]}\n');
  }

  final fm = StringBuffer()
    ..writeln('---')
    ..writeln('slug: ${t.slug}')
    ..writeln('title: ${t.title}')
    ..writeln('description: ${t.description}')
    ..writeln('heading: ${t.heading}')
    ..writeln('section: ${t.sectionNumber}')
    ..writeln('crumb: ${t.crumbLabel}');
  if (t.prevHref != null) {
    fm
      ..writeln('prev: ${t.prevHref}')
      ..writeln('prevLabel: ${t.prevLabel}');
  }
  if (t.nextHref != null) {
    fm
      ..writeln('next: ${t.nextHref}')
      ..writeln('nextLabel: ${t.nextLabel}');
  }
  fm.writeln('---');

  final out = Directory('${_root.path}/content/tutorials')..createSync(recursive: true);
  File('${out.path}/${t.slug}.md').writeAsStringSync('$fm${t.body}\n');
}

// --- section titles ---------------------------------------------------------
// The 101 index is generated from tutorial front matter, so section titles are
// the only 101 structure that needs translating. Seeded here from the English
// breadcrumbs; blurbs are backfilled from the existing 101 page.

void _writeSections(Map<int, String> sections) {
  final blurbs = _landingBlurbs();
  final buf = StringBuffer()..writeln('{');
  final keys = sections.keys.toList()..sort();
  for (var i = 0; i < keys.length; i++) {
    final n = keys[i];
    final comma = i == keys.length - 1 ? '' : ',';
    buf
      ..writeln('  "section$n": ${_json(sections[n]!)},')
      ..writeln('  "section${n}Blurb": ${_json(blurbs[n] ?? '')}$comma');
  }
  buf.writeln('}');
  final dir = Directory('${_root.path}/content')..createSync(recursive: true);
  File('${dir.path}/sections.json').writeAsStringSync(buf.toString());
}

Map<int, String> _landingBlurbs() {
  final html = File('${_root.path}/docs/101/index.html').readAsStringSync();
  final re = RegExp(
    r'<h2[^>]*>Section (\d+) · .*?</h2>\n  <p class="dim">(.*?)</p>',
    dotAll: true,
  );
  return {
    for (final m in re.allMatches(html))
      int.parse(m.group(1)!): m.group(2)!.trim(),
  };
}

// --- landing page -----------------------------------------------------------

void _extractLanding() {
  final html = File('${_root.path}/docs/index.html').readAsStringSync();
  var body = _main.firstMatch(html)!.group(1)!;

  final code = <String>[];
  body = body.replaceAllMapped(_playground, (m) {
    code.add(m.group(1)!);
    return '  {{playground:${code.length - 1}}}\n';
  });

  final codeDir = Directory('${_root.path}/content/code/_index')
    ..createSync(recursive: true);
  for (var i = 0; i < code.length; i++) {
    File('${codeDir.path}/$i.dart').writeAsStringSync('${code[i]}\n');
  }

  final fm = StringBuffer()
    ..writeln('---')
    ..writeln('slug: index')
    ..writeln('title: ${_title.firstMatch(html)!.group(1)}')
    ..writeln('description: ${_desc.firstMatch(html)!.group(1)}')
    ..writeln('---');

  final dir = Directory('${_root.path}/content/pages')..createSync(recursive: true);
  File('${dir.path}/index.md').writeAsStringSync('$fm${_trimBlankLines(body)}\n');
}

// --- 101 course index -------------------------------------------------------
// The 101 page is pure structure (sections -> function lists) plus a short
// intro. Capturing the link order and labels verbatim keeps `gt · gte · lt · lte`
// and friends intact; the builder regenerates the page per locale from this
// plus the translated section titles in sections.json.

int _extractCourse() {
  final html = File('${_root.path}/docs/101/index.html').readAsStringSync();

  final sectionRe = RegExp(
    r'<h2[^>]*>Section (\d+) · .*?</h2>\n  <p class="dim">.*?</p>\n  <ul class="fn-list">\n(.*?)\n  </ul>',
    dotAll: true,
  );
  final itemRe = RegExp(r'<li><a href="\.\./tutorials/([^"]*)">(.*?)</a></li>');

  var count = 0;
  final buf = StringBuffer()..writeln('{');
  final matches = sectionRe.allMatches(html).toList();
  for (var i = 0; i < matches.length; i++) {
    final m = matches[i];
    final items = itemRe.allMatches(m.group(2)!).toList();
    final entries = items.map((it) {
      count++;
      return '    {"href": ${_json(it.group(1)!)}, "label": ${_json(it.group(2)!)}}';
    }).join(',\n');
    buf
      ..writeln('  "${m.group(1)}": [')
      ..writeln(entries)
      ..writeln('  ]${i == matches.length - 1 ? '' : ','}');
  }
  buf.writeln('}');
  File('${_root.path}/content/course.json').writeAsStringSync(buf.toString());

  // Intro prose (everything before the first section heading) becomes the
  // translatable part of the 101 page.
  final main = _main.firstMatch(html)!.group(1)!;
  final intro = _trimBlankLines(main.substring(0, main.indexOf('  <h2')));
  final fm = StringBuffer()
    ..writeln('---')
    ..writeln('slug: 101')
    ..writeln('title: ${_title.firstMatch(html)!.group(1)}')
    ..writeln('description: ${_desc.firstMatch(html)!.group(1)}')
    ..writeln('---');
  File('${_root.path}/content/pages/101.md').writeAsStringSync('$fm$intro\n');

  return count;
}

/// Strips leading/trailing blank lines while preserving the indentation of the
/// first content line, so extracted bodies drop straight back into <main>.
String _trimBlankLines(String s) =>
    s.replaceAll(RegExp(r'^\s*\n'), '').replaceAll(RegExp(r'\s+$'), '');

String _json(String s) =>
    '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll('\n', r'\n')}"';
