// Markdown → block HTML for the theory textbook (content/theory/ → docs/theory/).
//
// The unit of output is a *block* — one paragraph, heading, figure, table or
// code listing. The viewer (docs/js/theorybook.js) measures blocks and flows
// them into fixed-size pages at runtime, exactly like the print manuscript
// pipeline it is modelled on: the build never decides where a page break goes,
// because the page size depends on the reader's viewport.
//
// Supported: h1-h3, paragraphs, `**bold**`, `*em*`, `` `code` ``, [links],
// fenced code (```dart run makes it runnable), blockquotes (🎓 depth boxes and
// goal boxes), ![figures](diagrams/x.svg) inlined as SVG, *captions*, bullet
// and numbered lists, pipe tables, and `---` rules.
library;

import 'dart:io';

/// One converted chapter: its blocks, plus the headings the viewer needs to
/// build a table of contents.
class TheoryChapter {
  TheoryChapter(this.number, this.title, this.blocks);

  final int number; // 0 = front matter (no chapter opener)
  final String title;
  final List<String> blocks;
}

TheoryChapter convertChapter(
  String markdown, {
  required int number,
  required String title,
  required String diagramsDir,
  String? partLabel,
  String? partBlurb,
  String Function(String code)? artifact,
}) {
  final c = _Converter(
    number: number,
    diagramsDir: diagramsDir,
    partLabel: partLabel,
    partBlurb: partBlurb,
    title: title,
    artifact: artifact,
  );
  return TheoryChapter(number, title, c.run(markdown));
}

class _Converter {
  _Converter({
    required this.number,
    required this.diagramsDir,
    required this.title,
    this.partLabel,
    this.partBlurb,
    this.artifact,
  });

  final int number;
  final String diagramsDir;
  final String title;
  final String? partLabel;
  final String? partBlurb;

  /// Returns the `data-pg` attribute for a listing that has a build-time
  /// artifact, or the empty string. Injected so this file stays free of IO.
  final String Function(String code)? artifact;

  final blocks = <String>[];
  final _para = <String>[];
  int _fig = 0;
  int _run = 0;

  List<String> run(String md) {
    final lines = md.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('```')) {
        i = _fence(lines, i);
      } else if (line.startsWith('# ')) {
        _flush();
        blocks.add(_chapterOpen(line.substring(2).trim()));
      } else if (line.startsWith('## ')) {
        _flush();
        blocks.add(_h2(line.substring(3).trim()));
      } else if (line.startsWith('### ')) {
        _flush();
        blocks.add('<h3>${_inline(line.substring(4).trim())}</h3>');
      } else if (line.startsWith('> ')) {
        i = _quote(lines, i);
      } else if (line.startsWith('![')) {
        _flush();
        blocks.add(_figure(line));
      } else if (line.startsWith('| ')) {
        i = _table(lines, i);
      } else if (line.startsWith('- ') || _ordered.hasMatch(line)) {
        i = _list(lines, i);
      } else if (line.trim() == '---') {
        _flush();
        blocks.add('<hr>');
      } else if (line.trim().isEmpty) {
        _flush();
      } else if (_caption.hasMatch(line.trim())) {
        _flush();
        blocks.add(
          '<p class="cap">'
          '${_inline(_caption.firstMatch(line.trim())!.group(1)!)}</p>',
        );
      } else {
        _para.add(line.trim());
      }
    }
    _flush();
    return blocks;
  }

  static final _ordered = RegExp(r'^\d+\. ');
  static final _caption = RegExp(r'^\*([^*].*)\*$');

  void _flush() {
    if (_para.isEmpty) return;
    blocks.add('<p>${_inline(_para.join(' '))}</p>');
    _para.clear();
  }

  String _chapterOpen(String heading) {
    final b = StringBuffer('<div class="ch-open" data-chapter-start="1">');
    if (partLabel != null) {
      b.write('<div class="part-tag">${_esc(partLabel!)}</div>');
      if (partBlurb != null) {
        b.write('<div class="part-blurb">${_inline(partBlurb!)}</div>');
      }
    }
    if (number > 0) b.write('<div class="ch-num">$number</div>');
    b.write('<div class="ch-title">${_inline(heading)}</div></div>');
    return b.toString();
  }

  // `## Exercises` and `## Solutions` are load-bearing: the viewer starts the
  // exercises on a recto page and the solutions after a page turn, so a reader
  // cannot see the answers while looking at the questions.
  String _h2(String text) {
    final id = 'ch$number-${_slug(text)}';
    final marker = text.toLowerCase() == 'exercises'
        ? ' data-exercise="1"'
        : (text.toLowerCase() == 'solutions' ? ' data-answers="1"' : '');
    return '<h2 id="$id"$marker>${_inline(text)}</h2>';
  }

  /// Fenced code. ```dart run gets a Run button; every other fence is a
  /// listing. Each source line becomes its own `.cl` span so the viewer can
  /// reconstruct the exact program text after the browser has wrapped it.
  int _fence(List<String> lines, int start) {
    _flush();
    final info = lines[start].substring(3).trim();
    final code = <String>[];
    var i = start + 1;
    while (i < lines.length && !lines[i].startsWith('```')) {
      code.add(lines[i]);
      i++;
    }
    final lang = info.split(RegExp(r'\s+')).first;
    final runnable = info.split(RegExp(r'\s+')).contains('run');
    final pre =
        '<pre class="code" data-lang="${_esc(lang)}"><code>'
        '${_codeLines(code)}</code></pre>';
    if (!runnable) {
      blocks.add(pre);
      return i;
    }
    _run++;
    // The listing is a complete program, so the text between the fences is
    // exactly what gets compiled — precompiled at build time and stamped here
    // as `data-pg`, so an unedited listing runs without a network round trip.
    final source = code.join('\n').trimRight().replaceFirst(RegExp(r'^\n+'), '');
    final pg = artifact == null ? '' : artifact!(source);
    blocks.add(
      '<div class="runwrap" data-ch="$number" data-idx="$_run"$pg>'
      '$pre'
      '<div class="runbar"><button class="run-btn" type="button"></button>'
      '<button class="edit-btn" type="button"></button>'
      '<span class="run-status"></span></div>'
      '<div class="run-out" hidden><div class="run-out-bar"><span '
      'class="run-out-title"></span>'
      '<button class="run-close" type="button"></button></div>'
      '<pre class="run-log"></pre></div>'
      '</div>',
    );
    return i;
  }

  static String _codeLines(List<String> code) => code
      .map((l) => '<span class="cl">${_esc(l).isEmpty ? ' ' : _esc(l)}</span>')
      .join();

  /// The learning-objectives box, told apart by its *shape*: a fully bold
  /// first line followed by nothing but bullets.
  ///
  /// It used to be matched on the literal `**In this chapter**`, which is
  /// English — so every translated chapter lost the styling and rendered the
  /// box as a plain pull quote. The Korean edition had 22 of them and showed
  /// none. Across the book this shape matches those 22 and none of the other
  /// 27 blockquotes, in any language, because a depth box opens with 🎓 and a
  /// pull quote is prose rather than a bullet list.
  static bool _isGoals(List<String> body) {
    final lines = body.where((l) => l.trim().isNotEmpty).toList();
    if (lines.length < 2) return false;
    if (!RegExp(r'^\*\*.+\*\*$').hasMatch(lines.first.trim())) return false;
    // A bullet may wrap. English objectives happen to fit on one line each;
    // a translation of the same sentence usually does not, and the first
    // version of this check called those chapters plain quotes — the same
    // English-shaped assumption it was written to remove.
    var bullets = 0;
    for (final l in lines.skip(1)) {
      if (l.startsWith('- ')) {
        bullets++;
      } else if (!l.startsWith(' ')) {
        return false; // prose, not a wrapped bullet
      }
    }
    return bullets > 0;
  }

  /// Blockquotes carry three roles, told apart by their content: the learning
  /// objectives that open a chapter, 🎓 depth boxes (skippable theory), and
  /// plain pull quotes.
  int _quote(List<String> lines, int start) {
    _flush();
    final body = <String>[];
    var i = start;
    while (i < lines.length) {
      final l = lines[i];
      if (l.startsWith('> ')) {
        body.add(l.substring(2));
      } else if (l == '>') {
        body.add('');
      } else {
        break;
      }
      i++;
    }
    final text = body.join('\n');
    final cls = text.contains('🎓') ? 'deep' : (_isGoals(body) ? 'goals' : 'quote');
    final inner = _Converter(
      number: number,
      diagramsDir: diagramsDir,
      title: title,
      // A quote never opens a part or a chapter.
    ).run(text);
    blocks.add('<blockquote class="$cls">${inner.join()}</blockquote>');
    return i - 1;
  }

  String _figure(String line) {
    final m = RegExp(r'^!\[(.*?)\]\((.+?)\)$').firstMatch(line.trim());
    if (m == null) return '<p>${_inline(line)}</p>';
    _fig++;
    final file = File('$diagramsDir/${m.group(2)!.split('/').last}');
    if (!file.existsSync()) {
      throw StateError('theory: missing diagram ${file.path}');
    }
    var svg = file.readAsStringSync().replaceFirst(
      RegExp(r'^<\?xml[^>]*\?>\s*'),
      '',
    );
    // Namespace every id: several figures share a page, and duplicate marker
    // ids silently make one figure's arrowheads render with the other's fill.
    final ns = 'f$number-$_fig';
    for (final id in RegExp(
      r'id="([^"]+)"',
    ).allMatches(svg).map((m) => m.group(1)!).toSet()) {
      svg = svg.replaceAll('id="$id"', 'id="$ns-$id"');
      svg = svg.replaceAll('url(#$id)', 'url(#$ns-$id)');
      svg = svg.replaceAll('href="#$id"', 'href="#$ns-$id"');
    }
    return '<figure class="fig" role="img" aria-label="${_esc(m.group(1)!)}">'
        '$svg</figure>';
  }

  int _list(List<String> lines, int start) {
    _flush();
    final ordered = _ordered.hasMatch(lines[start]);
    final items = <String>[];
    var i = start;
    while (i < lines.length) {
      final l = lines[i];
      if (l.startsWith('- ')) {
        items.add(l.substring(2).trim());
      } else if (_ordered.hasMatch(l)) {
        items.add(l.replaceFirst(_ordered, '').trim());
      } else if (l.startsWith('  ') &&
          l.trim().isNotEmpty &&
          items.isNotEmpty) {
        items[items.length - 1] += ' ${l.trim()}'; // continuation line
      } else {
        break;
      }
      i++;
    }
    final tag = ordered ? 'ol' : 'ul';
    final body = items.map((t) => '<li>${_inline(t)}</li>').join();
    blocks.add('<$tag>$body</$tag>');
    return i - 1;
  }

  int _table(List<String> lines, int start) {
    _flush();
    final rows = <List<String>>[];
    var i = start;
    while (i < lines.length && lines[i].trimLeft().startsWith('|')) {
      final cells = lines[i]
          .trim()
          .replaceAll(RegExp(r'^\||\|$'), '')
          .split('|')
          .map((c) => c.trim())
          .toList();
      rows.add(cells);
      i++;
    }
    if (rows.length < 2) return i - 1;
    final b = StringBuffer('<table class="tbl"><thead><tr>');
    for (final c in rows.first) {
      b.write('<th>${_inline(c)}</th>');
    }
    b.write('</tr></thead><tbody>');
    for (final row in rows.skip(2)) {
      b.write('<tr>');
      for (final c in row) {
        b.write('<td>${_inline(c)}</td>');
      }
      b.write('</tr>');
    }
    b.write('</tbody></table>');
    blocks.add(b.toString());
    return i - 1;
  }

  /// Inline markup. Code spans are stashed first so `*` inside a snippet
  /// cannot be read as emphasis.
  static String _inline(String s) {
    final codes = <String>[];
    var out = _esc(s);
    out = out.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) {
      codes.add('<code>${m.group(1)}</code>');
      return '\u0000${codes.length - 1}\u0000';
    });
    out = out.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
      (m) => '<a href="${m.group(2)}">${m.group(1)}</a>',
    );
    out = out.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (m) => '<strong>${m.group(1)}</strong>',
    );
    out = out.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^*\n]+)\*(?!\*)'),
      (m) => '<em>${m.group(1)}</em>',
    );
    out = out.replaceAllMapped(
      RegExp('\u0000(\\d+)\u0000'),
      (m) => codes[int.parse(m.group(1)!)],
    );
    return out;
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  static String _slug(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
