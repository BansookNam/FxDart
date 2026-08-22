// Strips comments from Dart source read on stdin, writing the result to
// stdout. Used by tools/build_single_file.sh on the playground bundle.
//
// Why the bundle drops its comments
// ---------------------------------
// A playground snippet's artifact id is a hash of (bundle + snippet), so it
// changes whenever docs/assets/fxdart_single.dart changes — and that file is
// lib/ concatenated verbatim. A dartdoc-only edit to lib/ therefore rotated
// every artifact id and rewrote the `data-pg` attribute on ~1,900 generated
// HTML pages, which is a guaranteed conflict between any two branches that
// both touch lib/. Comments are about a quarter of the bundle and cannot
// affect what a snippet compiles to, so removing them makes a comment-only
// change to lib/ produce a byte-identical bundle: no id rotation, no HTML
// churn, no conflict.
//
// `// ignore:` and `// ignore_for_file:` are kept. They are analyzer
// directives rather than prose, and CI analyzes the generated bundle — drop
// the two `annotate_redeclares` ignores in non_empty_list.dart and that step
// fails. They are static, so keeping them costs no churn.
//
// This is a scanner, not a regex, because `//` inside a string literal is not
// a comment. It tracks the four quote forms, raw strings, escapes, and `${}`
// interpolation, which re-enters code where a nested string can start again.
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final source = await stdin.transform(utf8.decoder).join();
  stdout.write(stripComments(source));
}

/// Returns [source] with every comment removed except analyzer `ignore`
/// directives.
///
/// A dropped comment takes the rest of its line with it, and if that leaves
/// the line blank the line itself goes too — so stripping a dartdoc block does
/// not leave a run of empty lines behind.
String stripComments(String source) {
  final out = StringBuffer();
  // The line being assembled. Held apart from [out] so that "is this line
  // blank so far" and "trim its trailing spaces" stay O(line), not O(output).
  final line = StringBuffer();
  void flush() {
    out.write(line);
    line.clear();
  }

  void emit(String text) {
    for (var k = 0; k < text.length; k++) {
      final ch = text[k];
      line.write(ch);
      if (ch == '\n') flush();
    }
  }

  final length = source.length;
  var i = 0;

  // Stack of string states suspended by an open `${`. Inside the
  // interpolation we are in code; the matching `}` resumes the string.
  final interpolation = <_StringState>[];
  _StringState? string;

  while (i < length) {
    final c = source[i];

    if (string != null) {
      if (!string.raw && c == r'\' && i + 1 < length) {
        emit(source.substring(i, i + 2));
        i += 2;
        continue;
      }
      if (!string.raw && c == r'$' && i + 1 < length && source[i + 1] == '{') {
        interpolation.add(string);
        string = null;
        emit(r'${');
        i += 2;
        continue;
      }
      if (source.startsWith(string.quote, i)) {
        emit(string.quote);
        i += string.quote.length;
        string = null;
        continue;
      }
      emit(c);
      i++;
      continue;
    }

    // --- in code ---
    if (c == '}' && interpolation.isNotEmpty) {
      emit(c);
      i++;
      string = interpolation.removeLast();
      continue;
    }

    if (c == '/' && i + 1 < length && source[i + 1] == '/') {
      final end = _lineEnd(source, i);
      final comment = source.substring(i, end);
      if (_isIgnoreDirective(comment)) {
        emit(comment);
        i = end;
        continue;
      }
      if (_isBlank(line)) {
        // Nothing but whitespace before it: drop the whole line.
        line.clear();
        i = end < length ? end + 1 : end;
      } else {
        _trimTrailingSpaces(line);
        i = end;
      }
      continue;
    }

    if (c == '/' && i + 1 < length && source[i + 1] == '*') {
      var depth = 1;
      var j = i + 2;
      while (j < length && depth > 0) {
        if (source.startsWith('/*', j)) {
          depth++;
          j += 2;
        } else if (source.startsWith('*/', j)) {
          depth--;
          j += 2;
        } else {
          j++;
        }
      }
      if (_isBlank(line) && _blankThroughNewline(source, j)) {
        line.clear();
        i = _lineEnd(source, j) + 1;
      } else {
        if (!_isBlank(line)) _trimTrailingSpaces(line);
        i = j;
      }
      continue;
    }

    final start = _stringStartAt(source, i);
    if (start != null) {
      emit(source.substring(i, i + start.consumed));
      i += start.consumed;
      string = start.state;
      continue;
    }

    emit(c);
    i++;
  }

  flush();
  return out.toString();
}

class _StringState {
  const _StringState(this.quote, this.raw);
  final String quote;
  final bool raw;
}

class _StringStart {
  const _StringStart(this.state, this.consumed);
  final _StringState state;
  final int consumed;
}

/// Recognises a string literal opening at [i], including a leading `r`.
_StringStart? _stringStartAt(String source, int i) {
  var j = i;
  var raw = false;
  if (source[j] == 'r' &&
      j + 1 < source.length &&
      (source[j + 1] == "'" || source[j + 1] == '"') &&
      (i == 0 || !_isIdentifierPart(source[i - 1]))) {
    raw = true;
    j++;
  }
  if (j >= source.length) return null;
  final c = source[j];
  if (c != "'" && c != '"') return null;
  final triple = c * 3;
  if (source.startsWith(triple, j)) {
    return _StringStart(_StringState(triple, raw), j - i + 3);
  }
  return _StringStart(_StringState(c, raw), j - i + 1);
}

final _identifierPart = RegExp(r'[A-Za-z0-9_$]');
bool _isIdentifierPart(String c) => _identifierPart.hasMatch(c);

/// True for `// ignore: …` and `// ignore_for_file: …`, the analyzer
/// directives the generated bundle has to keep for `dart analyze` to pass.
bool _isIgnoreDirective(String comment) {
  final body = comment.replaceFirst(RegExp(r'^//+\s*'), '');
  return body.startsWith('ignore:') || body.startsWith('ignore_for_file:');
}

int _lineEnd(String source, int from) {
  final n = source.indexOf('\n', from);
  return n == -1 ? source.length : n;
}

bool _blankThroughNewline(String source, int from) {
  for (var k = from; k < source.length; k++) {
    final c = source[k];
    if (c == '\n') return true;
    if (c != ' ' && c != '\t' && c != '\r') return false;
  }
  return false;
}

bool _isBlank(StringBuffer line) => line.toString().trim().isEmpty;

void _trimTrailingSpaces(StringBuffer line) {
  final s = line.toString();
  var end = s.length;
  while (end > 0 && (s[end - 1] == ' ' || s[end - 1] == '\t')) {
    end--;
  }
  line.clear();
  line.write(s.substring(0, end));
}
