// Structural checker for translated tutorial pages.
//
//   dart run tool/check_translation.dart ko tutorials/take.md [more...]
//   dart run tool/check_translation.dart ko            # every file present
//
// Verifies that a translation differs from its English source only in prose:
// front matter keys and non-translatable values match, placeholders keep their
// order, and every HTML tag, attribute and href survives untouched. Exits
// non-zero and prints one line per problem, so a translator can fix and re-run.
import 'dart:io';

final root = Directory.current.path;

/// Front-matter keys whose value must be byte-identical to English.
const _verbatimKeys = {
  'slug',
  'section',
  'prev',
  'next',
  'heading',
  'prevLabel',
  'nextLabel',
  'crumb',
};

/// Tutorial titles are `<fn> — FxDart 101` — all identifier and brand, no
/// prose — so they stay verbatim too. The two hand-written landing pages
/// (pages/index.md, pages/101.md) do have real prose in their titles.
bool _titleIsVerbatim(String rel) => rel.startsWith('tutorials/');

final _placeholder = RegExp(r'\{\{(?:root|signature|playground:\d+)\}\}');
final _tag = RegExp(r'<[^>]+>');
final _href = RegExp(r'href="([^"]*)"');

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: check_translation.dart <locale> [relPath...]');
    exit(2);
  }
  final locale = args.first;
  var rels = args.skip(1).toList();
  if (rels.isEmpty) {
    final dir = Directory('$root/i18n/$locale/tutorials');
    if (!dir.existsSync()) {
      stderr.writeln('no translations at i18n/$locale/tutorials');
      exit(2);
    }
    rels = dir
        .listSync()
        .whereType<File>()
        .map((f) => 'tutorials/${f.uri.pathSegments.last}')
        .where((p) => p.endsWith('.md'))
        .toList()
      ..sort();
  }

  final problems = <String>[];
  for (final rel in rels) {
    problems.addAll(_check(locale, rel));
  }

  if (problems.isEmpty) {
    stdout.writeln('ok — ${rels.length} file(s) structurally match English');
    return;
  }
  for (final p in problems) {
    stdout.writeln(p);
  }
  stdout.writeln('${problems.length} problem(s)');
  exit(1);
}

List<String> _check(String locale, String rel) {
  final out = <String>[];
  void bad(String msg) => out.add('i18n/$locale/$rel: $msg');

  final src = File('$root/content/$rel');
  final dst = File('$root/i18n/$locale/$rel');
  if (!src.existsSync()) return ['content/$rel: no such English source'];
  if (!dst.existsSync()) return ['i18n/$locale/$rel: missing'];

  final a = _split(src.readAsStringSync());
  final b = _split(dst.readAsStringSync());
  if (a == null) return ['content/$rel: malformed front matter'];
  if (b == null) return ['i18n/$locale/$rel: malformed front matter'];

  // --- front matter
  if (!_sameList(a.metaKeys, b.metaKeys)) {
    bad('front-matter keys differ\n  english: ${a.metaKeys}\n  found:   ${b.metaKeys}');
  }
  for (final k in a.meta.keys) {
    final verbatim = _verbatimKeys.contains(k) || (k == 'title' && _titleIsVerbatim(rel));
    if (!verbatim) continue;
    if (!b.meta.containsKey(k)) continue;
    if (a.meta[k] != b.meta[k]) {
      bad('front matter "$k" must stay identical\n'
          '  english: ${a.meta[k]}\n  found:   ${b.meta[k]}');
    }
  }
  final desc = b.meta['description'];
  if (desc != null && desc == a.meta['description'] && desc.isNotEmpty) {
    bad('front matter "description" is still English');
  }

  // --- placeholders: same set, same order
  final pa = _placeholder.allMatches(a.body).map((m) => m[0]!).toList();
  final pb = _placeholder.allMatches(b.body).map((m) => m[0]!).toList();
  if (!_sameList(pa, pb)) {
    bad('placeholder mismatch\n  english: $pa\n  found:   $pb');
  }

  // --- markup: identical tag stream, identical link targets
  final ta = _tag.allMatches(a.body).map((m) => m[0]!).toList();
  final tb = _tag.allMatches(b.body).map((m) => m[0]!).toList();
  if (!_sameList(ta, tb)) {
    out.add('i18n/$locale/$rel: HTML tag stream differs from English\n'
        '${_firstDiff(ta, tb)}');
  }
  final ha = _href.allMatches(a.body).map((m) => m[1]!).toList();
  final hb = _href.allMatches(b.body).map((m) => m[1]!).toList();
  if (!_sameList(ha, hb)) {
    bad('link targets differ\n  english: $ha\n  found:   $hb');
  }

  // --- layout: the first body line's indentation is part of <main>
  final ia = _indent(a.body), ib = _indent(b.body);
  if (ia != ib) bad('first body line indent is $ib spaces, expected $ia');

  // --- a wholly untranslated body means the file is a copy, not a translation
  if (a.body.trim() == b.body.trim()) bad('body is identical to English');

  return out;
}

String _firstDiff(List<String> a, List<String> b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[i] != b[i]) {
      return '  first difference at tag $i\n'
          '    english: ${a[i]}\n    found:   ${b[i]}';
    }
  }
  return '  english has ${a.length} tags, translation has ${b.length}';
}

int _indent(String body) {
  final line = body.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
  return line.length - line.trimLeft().length;
}

bool _sameList(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _Doc {
  _Doc(this.meta, this.metaKeys, this.body);
  final Map<String, String> meta;
  final List<String> metaKeys;
  final String body;
}

/// Mirrors the front-matter parsing in build_docs.dart so this checker agrees
/// with the renderer about where metadata ends and prose begins.
_Doc? _split(String raw) {
  final end = raw.indexOf('\n---\n', 4);
  if (!raw.startsWith('---\n') || end == -1) return null;
  final meta = <String, String>{};
  final keys = <String>[];
  for (final line in raw.substring(4, end).split('\n')) {
    final i = line.indexOf(':');
    if (i > 0) {
      final k = line.substring(0, i).trim();
      keys.add(k);
      meta[k] = line.substring(i + 1).trim();
    }
  }
  final body = raw
      .substring(end + 5)
      .replaceAll(RegExp(r'^\s*\n'), '')
      .replaceAll(RegExp(r'\s+$'), '');
  return _Doc(meta, keys, body);
}
