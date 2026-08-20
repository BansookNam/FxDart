// Paired, interleaved A/B benchmark runner for library changes.
//
//   dart run tool/ab_bench.dart recent-errors anomaly-context
//   dart run tool/ab_bench.dart --rounds 8 --scale 10000 ledger-diff
//   dart run tool/ab_bench.dart --rx even-totals
//   dart run tool/ab_bench.dart --ref 0.8.4 recent-errors
//   dart run tool/ab_bench.dart --ref main --all --rounds 20
//
// WHY THIS EXISTS, and why a results.json diff will not do
// -------------------------------------------------------
// Two separate `run_benchmarks.dart` runs cannot resolve a change smaller
// than ~5% on this machine. Proof: the `native` side links no fxdart code, so
// a lib/-only change leaves its binary byte-identical and its cross-run delta
// must be zero — measured instead at median -2.1%, stdev 5.1%, range -27.4%
// to +3.9%. Thermal and scheduler drift between runs is common-mode but
// large, and `--rounds 5` medians do not average it out.
//
// So: build BOTH variants of the same case, run them INTERLEAVED inside one
// session alternating which goes first each round, and pool the per-iteration
// samples per side. Drift then lands on both sides equally.
//
// WHAT IS HELD CONSTANT
// ---------------------
// Only `lib/` differs between the two sides. The working tree's case sources
// and harness are copied INTO the baseline worktree before compiling, so a
// change to a benchmark case cannot masquerade as a library win. (For a
// deliberate example rewrite — the Phase 4 fallback — that is the wrong
// comparison; measure those against `native` with the normal runner.)
//
// THE NOISE CONTROL
// -----------------
// The `native` side is compiled from both trees too and A/B'd the same way.
// It links no fxdart code, so its two binaries are identical and its reported
// delta is pure measurement noise. Read it first: if the control is not
// within about ±2%, the machine is too busy and the run means nothing.
//
// Resolution at the defaults is ~1.5%, against the ~5% floor of a
// results.json diff. Do not read a sub-2% fxdart delta as a real change.
import 'dart:convert';
import 'dart:io';

import '../benchmark/harness.dart' show resultPrefix;

final root = Directory.current.path;

/// Where the baseline worktree and both sets of binaries live. Under
/// `benchmark/.build/`, which is already gitignored.
String get _abDir => '$root/benchmark/.build/ab';
String get _treeDir => '$_abDir/baseline';

Future<void> main(List<String> argv) async {
  // 12 rounds x 5 iterations per side resolves ~1.5% at the headline scale and
  // costs ~15 s for one sync case. Measured on an idle M1 Max with the change
  // set to nothing at all: control -1.10%, fxdart +0.24%. Fewer rounds is not
  // worth it — at 6 the same null change read +1.58% / -0.87%.
  var rounds = 12;
  var iters = 5;
  var warmup = 2;
  var scale = 'full';
  var ref = 'HEAD';
  var rx = false;
  var keepTree = false;
  var all = false;
  final slugs = <String>[];

  for (var i = 0; i < argv.length; i++) {
    final a = argv[i];
    switch (a) {
      case '--rounds':
        rounds = int.parse(argv[++i]);
      case '--iters':
        iters = int.parse(argv[++i]);
      case '--warmup':
        warmup = int.parse(argv[++i]);
      case '--scale':
        scale = argv[++i];
      case '--ref':
        ref = argv[++i];
      case '--rx':
        rx = true;
      case '--keep-tree':
        keepTree = true;
      case '--all':
        all = true;
      default:
        if (a.startsWith('-')) {
          stderr.writeln('unknown flag: $a');
          exit(2);
        }
        slugs.add(a);
    }
  }
  final casesDir = rx ? 'cases-rx' : 'cases';
  final left = rx ? 'rxdart' : 'native';

  if (all) {
    if (slugs.isNotEmpty) {
      stderr.writeln('--all measures every case; it takes no slugs');
      exit(2);
    }
    slugs.addAll(
      Directory('$root/benchmark/$casesDir')
          .listSync()
          .whereType<Directory>()
          .map((d) => d.path.split(Platform.pathSeparator).last)
          .toList()
        ..sort(),
    );
  }
  if (slugs.isEmpty) {
    stderr.writeln(
      'usage: dart run tool/ab_bench.dart [--ref R] [--rounds N] [--iters N]\n'
      '                                   [--warmup N] [--scale 100|10000|full]\n'
      '                                   [--rx] [--keep-tree] (--all | <slug>...)',
    );
    exit(2);
  }

  for (final slug in slugs) {
    if (!Directory('$root/benchmark/$casesDir/$slug').existsSync()) {
      stderr.writeln('no such case: benchmark/$casesDir/$slug');
      exit(2);
    }
  }

  await _prepareBaseline(ref, keepTree);
  _syncCaseSources(casesDir, slugs);

  // Both sides of every case, from both trees: 4 binaries per case.
  final jobs = <(String slug, String impl, bool base)>[
    for (final slug in slugs)
      for (final impl in [left, 'fxdart'])
        for (final base in [true, false]) (slug, impl, base),
  ];
  await _compileAll(jobs, casesDir);

  stdout.writeln(
    '\nA/B  baseline=$ref  scale=$scale  rounds=$rounds  '
    'iters=$iters  warmup=$warmup',
  );
  stdout.writeln('=' * 72);

  final report = <(String slug, double control, double fxdart)>[];
  var worstControl = 0.0;
  for (final slug in slugs) {
    stdout.writeln('\n$slug');
    var control = 0.0;
    var fxdart = 0.0;
    for (final impl in [left, 'fxdart']) {
      final r = await _abOne(slug, impl, scale, rounds, iters, warmup);
      final tag = impl == 'fxdart' ? 'fxdart' : '$impl (control)';
      final line =
          '  ${tag.padRight(18)} '
          'base ${_ms(r.baseMedian).padLeft(9)}   '
          'head ${_ms(r.headMedian).padLeft(9)}   '
          '${_pct(r.delta).padLeft(8)}';
      stdout.writeln(line);
      if (impl == 'fxdart') {
        fxdart = r.delta;
        continue;
      }
      control = r.delta;
      if (control.abs() > worstControl.abs()) worstControl = control;
      if (control.abs() > _controlLimit) {
        stdout.writeln(
          '  !! control moved ${_pct(control)} — the machine is too busy for '
          'this measurement to mean anything.',
        );
      }
    }
    report.add((slug, control, fxdart));
  }
  stdout.writeln('\n${'=' * 72}');
  stdout.writeln('negative = faster after the change');

  final table = _reportTable(
    rows: report,
    ref: ref,
    scale: scale,
    rounds: rounds,
    iters: iters,
    warmup: warmup,
    control: left,
  );
  final out = File('$_abDir/report.md');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync('$table\n');
  stdout.writeln('\n$table\n\nwritten: ${out.path}');

  if (worstControl.abs() > _controlLimit) {
    stderr.writeln(
      'control moved ${_pct(worstControl)}, past the '
      '${_controlLimit.toStringAsFixed(1)}% limit — these numbers cannot carry '
      'a percentage claim. Rerun on an idle machine.',
    );
    exit(1);
  }
}

/// How far the control may drift before the run is declared unusable.
///
/// The control side links none of the changed library, so its two binaries are
/// identical and everything it reports is measurement noise. Past this much
/// noise a sub-5% reading is not resolvable, so the run exits non-zero rather
/// than hand back a number that looks publishable.
const _controlLimit = 2.0;

/// The per-case delta table, in the shape the CHANGELOG entries use.
String _reportTable({
  required List<(String, double, double)> rows,
  required String ref,
  required String scale,
  required int rounds,
  required int iters,
  required int warmup,
  required String control,
}) {
  final b = StringBuffer()
    ..writeln('# ab_bench — paired A/B against `$ref`')
    ..writeln()
    ..writeln(
      'scale `$scale` · rounds $rounds · iters $iters · warmup $warmup · '
      'negative = faster after the change',
    )
    ..writeln()
    ..writeln('| Case | fxdart | $control (control) |')
    ..writeln('|---|---:|---:|');
  for (final (slug, ctrl, fx) in rows) {
    b.writeln('| `$slug` | ${_pct(fx)} | ${_pct(ctrl)} |');
  }
  return b.toString().trimRight();
}

// --- one interleaved A/B ----------------------------------------------------

class _AbResult {
  _AbResult(this.baseMedian, this.headMedian);
  final double baseMedian;
  final double headMedian;

  /// Percent change of head against base; negative means head is faster.
  double get delta => (headMedian - baseMedian) / baseMedian * 100;
}

Future<_AbResult> _abOne(
  String slug,
  String impl,
  String scale,
  int rounds,
  int iters,
  int warmup,
) async {
  final base = <double>[];
  final head = <double>[];
  final checksums = <String>{};

  for (var r = 0; r < rounds; r++) {
    // Alternate which side runs first: whatever the first run of a pair pays
    // for (cold page cache, a core that has not yet clocked up) is then paid
    // by each side equally across the run.
    for (final isBase in r.isEven ? [true, false] : [false, true]) {
      final res = await _run(slug, impl, isBase, scale, iters, warmup);
      (isBase ? base : head).addAll(res.iterUs);
      checksums.add(res.checksum);
    }
  }
  if (checksums.length != 1) {
    throw StateError(
      '$slug/$impl: the two variants computed different answers — $checksums',
    );
  }
  return _AbResult(_median(base), _median(head));
}

class _Run {
  _Run(this.iterUs, this.checksum);
  final List<double> iterUs;
  final String checksum;
}

Future<_Run> _run(
  String slug,
  String impl,
  bool base,
  String scale,
  int iters,
  int warmup,
) async {
  final res = await Process.run(
    _binPath(slug, impl, base),
    const [],
    environment: {
      'BENCH_ITERS': '$iters',
      'BENCH_WARMUP': '$warmup',
      if (scale != 'full') 'BENCH_N': scale,
    },
    workingDirectory: root,
  );
  if (res.exitCode != 0) {
    throw StateError('$slug/$impl exited ${res.exitCode}: ${res.stderr}');
  }
  final line = (res.stdout as String)
      .split('\n')
      .lastWhere(
        (l) => l.startsWith(resultPrefix),
        orElse: () => throw StateError('$slug/$impl printed no result line'),
      );
  final r =
      jsonDecode(line.substring(resultPrefix.length)) as Map<String, dynamic>;
  if (r['aot'] != true) {
    throw StateError('$slug/$impl reported a JIT measurement');
  }
  return _Run([
    for (final v in r['iterUs'] as List) (v as num).toDouble(),
  ], r['checksum'] as String);
}

// --- the baseline worktree --------------------------------------------------

/// Checks [ref] out into a detached worktree under `benchmark/.build/ab/`.
///
/// A worktree, not a stash or a copy: the baseline has to be a real package
/// directory with its own `.dart_tool/` so `dart compile exe` resolves
/// `package:fxdart` to the BASELINE `lib/`, and it has to survive across many
/// edit/measure cycles in the working tree.
Future<void> _prepareBaseline(String ref, bool keepTree) async {
  final head = (await _git(['rev-parse', ref])).trim();
  final stamp = File('$_abDir/baseline.ref');
  final existing = Directory(_treeDir).existsSync();

  if (existing && !keepTree) {
    final current = stamp.existsSync() ? stamp.readAsStringSync().trim() : '';
    if (current == head) {
      stdout.writeln('baseline worktree at $ref (${head.substring(0, 8)})');
      return;
    }
    stdout.writeln('baseline moved → re-checking out ${head.substring(0, 8)}');
    await _git(['worktree', 'remove', '--force', _treeDir]);
    // The `_base` binaries were compiled against the OLD baseline's lib/, and
    // [_compileAll]'s staleness check only watches the case sources and the
    // *head* tree's lib/ — so without this they would silently survive a
    // baseline change and the run would measure the wrong pair of libraries.
    _dropBaseBinaries();
  } else if (existing) {
    stdout.writeln('reusing baseline worktree as-is (--keep-tree)');
    return;
  }

  Directory(_abDir).createSync(recursive: true);
  stdout.writeln('creating baseline worktree at ${head.substring(0, 8)}…');
  await _git(['worktree', 'add', '--detach', _treeDir, head]);
  final pub = await Process.run(Platform.executable, [
    'pub',
    'get',
  ], workingDirectory: _treeDir);
  if (pub.exitCode != 0) {
    throw StateError('pub get failed in the baseline worktree: ${pub.stderr}');
  }
  stamp.writeAsStringSync('$head\n');
}

/// Copies the WORKING TREE's case sources and harness over the baseline's, so
/// the only difference between the two binaries is `lib/`.
void _syncCaseSources(String casesDir, List<String> slugs) {
  File(
    '$root/benchmark/harness.dart',
  ).copySync('$_treeDir/benchmark/harness.dart');
  for (final slug in slugs) {
    final dst = Directory('$_treeDir/benchmark/$casesDir/$slug')
      ..createSync(recursive: true);
    for (final f in Directory(
      '$root/benchmark/$casesDir/$slug',
    ).listSync().whereType<File>()) {
      f.copySync('${dst.path}/${f.uri.pathSegments.last}');
    }
  }
}

/// Deletes every `_base` binary, so a baseline change forces a rebuild.
void _dropBaseBinaries() {
  final dir = Directory(_abDir);
  if (!dir.existsSync()) return;
  for (final f in dir.listSync()) {
    if (f is File && f.path.endsWith('_base')) f.deleteSync();
  }
}

Future<String> _git(List<String> args) async {
  final res = await Process.run('git', args, workingDirectory: root);
  if (res.exitCode != 0) {
    throw StateError('git ${args.join(' ')} failed: ${res.stderr}');
  }
  return res.stdout as String;
}

// --- compilation ------------------------------------------------------------

String _binPath(String slug, String impl, bool base) =>
    '$_abDir/${slug}_${impl}_${base ? 'base' : 'head'}';

Future<void> _compileAll(
  List<(String, String, bool)> jobs,
  String casesDir,
) async {
  // Rebuild whenever the tree that feeds a binary is newer than it. The head
  // side tracks the working tree's lib/; the base side only changes when the
  // baseline ref does, which `_prepareBaseline` handles by re-checkout.
  final headLib = _newest('$root/lib');
  final pending = jobs.where((j) {
    final out = File(_binPath(j.$1, j.$2, j.$3));
    if (!out.existsSync()) return true;
    final built = out.lastModifiedSync();
    final tree = j.$3 ? _treeDir : root;
    final srcDir = Directory('$tree/benchmark/$casesDir/${j.$1}');
    if (srcDir.listSync().whereType<File>().any(
      (f) => f.lastModifiedSync().isAfter(built),
    )) {
      return true;
    }
    if (!j.$3 && j.$2 == 'fxdart' && headLib.isAfter(built)) return true;
    return false;
  }).toList();
  if (pending.isEmpty) return;

  stdout.write('Compiling ${pending.length} binaries (AOT) ');
  var next = 0;
  final failed = <String>[];
  Future<void> worker() async {
    while (next < pending.length) {
      final (slug, impl, base) = pending[next++];
      final tree = base ? _treeDir : root;
      final res = await Process.run(Platform.executable, [
        'compile',
        'exe',
        '$tree/benchmark/$casesDir/$slug/$impl.dart',
        '-o',
        _binPath(slug, impl, base),
      ], workingDirectory: tree);
      if (res.exitCode != 0) failed.add('$slug/$impl/$tree: ${res.stderr}');
      stdout.write('.');
    }
  }

  await Future.wait([for (var i = 0; i < 6; i++) worker()]);
  stdout.writeln(' done');
  if (failed.isNotEmpty) {
    throw StateError('AOT compile failed:\n${failed.join('\n')}');
  }
}

DateTime _newest(String dir) {
  var newest = DateTime.fromMillisecondsSinceEpoch(0);
  for (final f in Directory(dir).listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart')) {
      final m = f.lastModifiedSync();
      if (m.isAfter(newest)) newest = m;
    }
  }
  return newest;
}

// --- formatting -------------------------------------------------------------

double _median(List<double> xs) {
  final s = [...xs]..sort();
  final mid = s.length ~/ 2;
  return s.length.isOdd ? s[mid] : (s[mid - 1] + s[mid]) / 2;
}

String _ms(double us) => us >= 1000
    ? '${(us / 1000).toStringAsFixed(2)} ms'
    : '${us.toStringAsFixed(1)} us';

String _pct(double p) => '${p >= 0 ? '+' : ''}${p.toStringAsFixed(2)}%';
