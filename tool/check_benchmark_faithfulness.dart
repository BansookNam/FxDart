// Guards AUTHORING.md's first rule: a benchmark case must re-implement the
// SAME pipeline shape as the example it claims to measure.
//
//   dart run tool/check_benchmark_faithfulness.dart
//
// It compares the multiset of *fxdart operators* used by
// `benchmark/cases[-rx]/<slug>/fxdart.dart` against
// `content/code-comparison[-rx]/<slug>/fxdart.dart`, and fails when the
// benchmark drops an operator the example uses.
//
// Why that direction: the failure mode this exists to catch is a benchmark
// case being "optimised" away from the library it is supposed to be measuring.
// `multi-currency-report` had its groupBy/sumBy/maxBy/uniq/sortBy replaced with
// hand-written loops and `toSet()`, so the page's bars measured a program the
// page did not show. Extra operators on the benchmark side are allowed — cases
// legitimately add `.first` / `.length` / `size()` to build an O(1) checksum,
// and scale the data with an outer loop.
import 'dart:io';

final root = Directory.current.path;

/// Names that may differ between the two files without the *shape* differing.
///
/// An example ends by printing (`forEach(print)`, `each`, `print`); a benchmark
/// ends by returning an O(1) checksum (`first`, `last`, `length`, `size`).
/// Neither is pipeline shape, so a difference here is not a faithfulness
/// failure.
const plumbing = {
  // checksum construction on the benchmark side
  'first', 'last', 'length', 'size', 'toList', 'join', 'elementAt',
  'isEmpty', 'isNotEmpty', 'sublist', 'toStringAsFixed', 'padRight', 'padLeft',
  // output on the example side
  'forEach', 'each', 'print', 'add', 'addAll', 'write', 'writeln',
};

/// Dart keywords and declaration noise that the declaration regex would
/// otherwise mistake for library functions.
const _notApi = {
  'for', 'if', 'while', 'switch', 'return', 'final', 'var', 'const', 'new',
  'assert', 'catch', 'throw', 'super', 'this', 'else', 'do', 'try', 'yield',
  'await', 'async', 'get', 'set', 'operator', 'factory', 'typedef', 'class',
  'extension', 'enum', 'mixin', 'import', 'export', 'library', 'part', 'show',
  'hide', 'as', 'is', 'in', 'on', 'with', 'implements', 'extends', 'void',
  'main', 'expect', 'test', 'group',
};

void main(List<String> args) {
  final names = _fxdartApiNames();
  var failures = 0;
  var checked = 0;

  for (final (casesDir, contentDir) in const [
    ('benchmark/cases', 'content/code-comparison'),
    ('benchmark/cases-rx', 'content/code-comparison-rx'),
  ]) {
    final dir = Directory('$root/$casesDir');
    if (!dir.existsSync()) continue;
    for (final d in dir.listSync().whereType<Directory>()) {
      final slug = d.path.split(Platform.pathSeparator).last;
      final bench = File('${d.path}/fxdart.dart');
      final example = File('$root/$contentDir/$slug/fxdart.dart');
      if (!bench.existsSync() || !example.existsSync()) continue;
      checked++;

      final want = _ops(_stripPrints(example.readAsStringSync()), names);
      final got = _ops(bench.readAsStringSync(), names);
      final missing = want.keys
          .where((op) => (got[op] ?? 0) == 0 && !plumbing.contains(op))
          .toList()
        ..sort();
      if (missing.isEmpty) continue;

      failures++;
      stderr.writeln('FAIL $casesDir/$slug');
      stderr.writeln('  example uses, benchmark does not: ${missing.join(', ')}');
      stderr.writeln('  → the benchmark is not measuring the published '
          'pipeline (AUTHORING.md: "same operators, same order, same '
          'algorithmic idea")');
    }
  }

  stdout.writeln('checked $checked benchmark cases against their examples; '
      '$failures unfaithful');
  if (failures > 0) exit(1);
}

/// Every public fxdart name worth tracking: top-level functions in `lib/src`
/// plus `Fx`/`FxAsync` members. Derived rather than hard-coded so a new
/// operator is covered the day it lands.
Set<String> _fxdartApiNames() {
  final names = <String>{};
  final decl = RegExp(
      r'^\s*(?:@\w+(?:\([^)]*\))?\s+)*[\w<>,\s\?\[\]\(\)]+?\s(\w+)\s*(?:<[^>]*>)?\s*\(',
      multiLine: true);
  for (final f in Directory('$root/lib/src').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    for (final m in decl.allMatches(f.readAsStringSync())) {
      final n = m.group(1)!;
      // Lower-case initial only: an upper-case name is a type/constructor
      // (`StateError`, `Duration`), not a pipeline operator.
      if (!n.startsWith('_') &&
          n.length > 1 &&
          n[0].toLowerCase() == n[0] &&
          !_notApi.contains(n)) {
        names.add(n);
      }
    }
  }
  return names;
}

/// Removes whole `print(...)` calls, including multi-line ones.
///
/// An example's last act is printing; a benchmark's is returning a checksum.
/// Operators that appear *only* inside a print — `fx(hits).head()` in a
/// interpolated string, `log.skip(1).forEach(print)` — are presentation, not
/// pipeline shape, and comparing them produces nothing but false alarms.
String _stripPrints(String source) {
  // `xs.skip(1).forEach(print)` is an output statement end to end — the whole
  // line is presentation, not the timed pipeline.
  source = source
      .split('\n')
      .where((l) => !l.contains('forEach(print)'))
      .join('\n');
  final out = StringBuffer();
  var i = 0;
  while (i < source.length) {
    final at = source.indexOf('print(', i);
    if (at < 0) {
      out.write(source.substring(i));
      break;
    }
    out.write(source.substring(i, at));
    var depth = 0;
    var j = at + 'print'.length;
    for (; j < source.length; j++) {
      final c = source[j];
      if (c == '(') depth++;
      if (c == ')') {
        depth--;
        if (depth == 0) {
          j++;
          break;
        }
      }
    }
    i = j;
  }
  return out.toString();
}

/// Multiset of fxdart operator names used in [source] — `.op(` calls and bare
/// `op(` calls, restricted to names the library actually defines.
Map<String, int> _ops(String source, Set<String> names) {
  final body = source
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//'))
      .join('\n');
  final out = <String, int>{};
  for (final m in RegExp(r'\.?\b(\w+)\s*\(').allMatches(body)) {
    final n = m.group(1)!;
    if (names.contains(n)) out[n] = (out[n] ?? 0) + 1;
  }
  return out;
}
