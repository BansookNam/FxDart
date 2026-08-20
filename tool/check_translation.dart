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
///
/// `heading` is deliberately absent: build_docs.dart:323-328 classifies it as
/// prose alongside `title` and `description`. Code-only tutorial headings are
/// classified separately below; every heading with surrounding prose must be
/// translated.
const _verbatimKeys = {
  'slug',
  'section',
  'prev',
  'next',
  'prevLabel',
  'nextLabel',
  'crumb',
};

/// The brand suffix every tutorial title carries.
const _brandSuffix = ' — FxDart 101';

/// Most tutorial titles are `<fn> — FxDart 101` — one identifier plus brand,
/// no prose — so they stay verbatim. Seventeen of them lead with a real
/// sentence instead (`Error accumulation`, `predicate combinators`,
/// `mapValues, mapKeys &amp; mapEntries`), and those must be translated. A
/// lead that is a single bare identifier is the only verbatim case; anything
/// with a space, comma or connective is prose. The two hand-written landing
/// pages (pages/index.md, pages/101.md) also have real prose in their titles.
bool _titleIsVerbatim(String rel, String englishTitle) {
  if (!rel.startsWith('tutorials/')) return false;
  if (!englishTitle.endsWith(_brandSuffix)) return false;
  final lead = englishTitle
      .substring(0, englishTitle.length - _brandSuffix.length)
      .trim();
  return _bareIdentifier.hasMatch(lead);
}

final _bareIdentifier = RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$');

/// A heading made entirely from one or more rendered identifiers.
///
/// Punctuation between `<code>` spans is part of the code label and therefore
/// stays byte-identical. Any text outside those spans makes the heading prose.
final _codeOnlyHeading = RegExp(
  r'^<code>[^<]+</code>(?:\s*(?:,|·|&amp;)\s*<code>[^<]+</code>)*$',
);
final _placeholder = RegExp(r'\{\{(?:root|signature|playground:\d+)\}\}');
final _tag = RegExp(r'<[^>]+>');
final _href = RegExp(r'href="([^"]*)"');

/// Fenced blocks and inline spans hold Dart, Scala and Kotlin source, where a
/// bare `<` is a generic bracket or an arrow — not markup. Extracting tags
/// from them yields garbage like `<- parseId(raw) }` (theory chapter 7), so
/// code is removed from both sides before the tag streams are compared.
final _fenced = RegExp(r'^```.*?^```', multiLine: true, dotAll: true);
final _inlineCode = RegExp(r'(`+)(?:(?!\1).)*\1', dotAll: true);

String _stripCode(String body) =>
    body.replaceAll(_fenced, '').replaceAll(_inlineCode, '');

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: check_translation.dart <locale> [relPath...]');
    exit(2);
  }
  final locale = args.first;
  var rels = args.skip(1).toList();
  if (rels.isEmpty) {
    if (!Directory('$root/i18n/$locale').existsSync()) {
      stderr.writeln('no translations at i18n/$locale');
      exit(2);
    }
    rels = _translatable();
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

/// Every English page a locale is expected to carry, mirroring
/// `_translatable()` in build_docs.dart:133-143 — the 300 rendered pages under
/// `pages/`, `theory/`, `tutorials/` and the `comparison*` families. The
/// `code*` directories hold source samples and their AUTHORING notes, which
/// are never rendered per-locale, and `theory/PLAN.md` is the writing plan
/// rather than a chapter.
///
/// Driving the default run off the *English* set — not off whatever the locale
/// happens to have — is what lets an absent translation be reported as
/// `missing` instead of silently passing.
List<String> _translatable() {
  const pageDirs = {'pages', 'theory', 'tutorials'};
  final base = Directory('$root/content');
  return base
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.substring(base.path.length + 1))
      .where((p) => p.endsWith('.md') && p != 'theory/PLAN.md')
      .where((p) {
        final dir = p.split('/').first;
        return pageDirs.contains(dir) || dir.startsWith('comparison');
      })
      .toList()
    ..sort();
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
    bad(
      'front-matter keys differ\n  english: ${a.metaKeys}\n  found:   ${b.metaKeys}',
    );
  }
  for (final k in a.meta.keys) {
    if (!b.meta.containsKey(k)) continue;
    final english = a.meta[k] ?? '';
    final translated = b.meta[k]!;
    final verbatim =
        _verbatimKeys.contains(k) ||
        (k == 'title' && _titleIsVerbatim(rel, english)) ||
        (k == 'heading' && _codeOnlyHeading.hasMatch(english));
    if (verbatim) {
      if (english != translated) {
        bad(
          'front matter "$k" must stay identical\n'
          '  english: $english\n  found:   $translated',
        );
      }
      continue;
    }
    if ((k == 'title' || k == 'heading' || k == 'description') &&
        english.isNotEmpty &&
        translated == english) {
      bad('front matter "$k" is still English');
    }
  }

  // --- placeholders: same set, same order
  final pa = _placeholder.allMatches(a.body).map((m) => m[0]!).toList();
  final pb = _placeholder.allMatches(b.body).map((m) => m[0]!).toList();
  if (!_sameList(pa, pb)) {
    bad('placeholder mismatch\n  english: $pa\n  found:   $pb');
  }

  // --- markup: identical tag stream, identical link targets
  final proseA = _stripCode(a.body), proseB = _stripCode(b.body);
  final ta = _tag.allMatches(proseA).map((m) => m[0]!).toList();
  final tb = _tag.allMatches(proseB).map((m) => m[0]!).toList();
  if (!_sameList(ta, tb)) {
    out.add(
      'i18n/$locale/$rel: HTML tag stream differs from English\n'
      '${_firstDiff(ta, tb)}',
    );
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
  final line = body
      .split('\n')
      .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
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
