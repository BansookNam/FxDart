// Collected runner for the DartComparison benchmarks.
//
//   dart run benchmark/run_benchmarks.dart              # all cases, all scales
//   dart run benchmark/run_benchmarks.dart food-spending top-expenses
//   dart run benchmark/run_benchmarks.dart --rounds 3   # base rounds (default 3)
//   dart run benchmark/run_benchmarks.dart --smoke      # 1 iteration, no warmup (sanity only)
//   dart run benchmark/run_benchmarks.dart --scales 100,full
//   dart run benchmark/run_benchmarks.dart --report-only # re-derive verdicts +
//                                            reports from results.json without
//                                            re-measuring (after a rule change)
//
// Every case runs at three scales — N=100, N=10,000, and its headline N
// (1M for sync cases; the case's own N for async ones) — so the site can
// show where the implementations diverge as data grows. Cases read BENCH_N
// at runtime (see harness.caseN), so each side is AOT-compiled once and the
// same binary serves every scale.
//
// Each side of each case is AOT-compiled (`dart compile exe`) and runs as a
// FRESH process. AOT rather than `dart run` because under JIT the peak-RSS
// numbers measure the VM compiling the code, not the pipeline: an empty
// script peaks at ~166 MB and a 3-element fxdart pipeline at ~376 MB on the
// same machine. AOT removes the JIT from the process, so both sides carry an
// identical small runtime baseline and the RSS difference is real pipeline
// behavior. Sides run interleaved (native, fxdart, native, …) so thermal
// drift hits both equally. When the two medians land within [tieMarginPct],
// that scale is re-run for up to [maxRounds] total rounds before being called
// a tie; the rounds count is recorded so the report can say "averaged over
// N runs".
//
// Output: benchmark/results/results.json (consumed by tool/build_docs.dart to
// render the per-page bar charts) and benchmark/results/SUMMARY.md.
import 'dart:convert';
import 'dart:io';

import 'harness.dart' show resultPrefix;

const tieMarginPct = 5.0;

/// Absolute time floor: two sides within this of each other are a tie no
/// matter the ratio — declaring a "winner" over an imperceptible difference
/// would overstate a distinction no user of the program could ever notice.
/// 0.6 ms is the smallest floor at which every N=100 case ties (the largest
/// N=100 gap measured is ~0.55 ms, an async retry case).
const tieAbsMs = 0.6;
const maxRounds = 5;

/// Scale labels in run order. `full` means the case's headline N.
const allScales = ['100', '10000', 'full'];

final root = File(Platform.script.toFilePath()).parent.parent.path;

Future<void> main(List<String> args) async {
  var rounds = 3;
  var smoke = false;
  var scales = allScales;
  final onlySlugs = <String>[];
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--report-only':
        return _reportOnly();
      case '--rounds':
        rounds = int.parse(args[++i]);
      case '--smoke':
        smoke = true;
      case '--scales':
        scales = args[++i].split(',');
        if (scales.any((s) => !allScales.contains(s))) {
          stderr.writeln('unknown scale in $scales (allowed: $allScales)');
          exit(1);
        }
      default:
        onlySlugs.add(args[i]);
    }
  }

  final meta = _loadMeta();
  final caseDirs = Directory('$root/benchmark/cases')
      .listSync()
      .whereType<Directory>()
      .map((d) => d.path.split(Platform.pathSeparator).last)
      .where((s) => onlySlugs.isEmpty || onlySlugs.contains(s))
      .toList()
    ..sort((a, b) => (meta[a]?.order ?? 999).compareTo(meta[b]?.order ?? 999));
  if (caseDirs.isEmpty) {
    stderr.writeln('no benchmark cases matched ${onlySlugs.join(', ')}');
    exit(1);
  }

  final machine = _machineInfo();
  stdout.writeln('Machine: ${machine['cpu']}, ${machine['ramGb']} GB RAM, '
      'Dart ${machine['dart']}');
  stdout.writeln('Cases: ${caseDirs.length}, scales: ${scales.join('/')}, '
      'base rounds: $rounds (tie margin ${tieMarginPct.toStringAsFixed(0)}% '
      '→ up to $maxRounds rounds)\n');

  await _compileAll(caseDirs);

  // Partial runs (a slug subset and/or a scale subset) merge into the
  // existing results.json instead of clobbering the cases they didn't run.
  final outFile = File('$root/benchmark/results/results.json');
  final cases = <String, Object?>{};
  if (outFile.existsSync()) {
    try {
      final existing = jsonDecode(outFile.readAsStringSync());
      cases.addAll((existing['cases'] as Map).cast<String, Object?>());
    } catch (_) {/* corrupt or old-format file — start fresh */}
  }
  var failures = 0;
  for (final slug in caseDirs) {
    stdout.write('#${meta[slug]?.order ?? '?'} $slug '.padRight(36));
    // Carry over scales this invocation isn't running (e.g. --scales 100).
    final scaleResults = <String, Object?>{
      ...?((cases[slug] as Map?)?['scales'] as Map?)?.cast<String, Object?>(),
    };
    final lineParts = <String>[];
    for (final scale in scales) {
      try {
        final r = await _runCase(slug, scale, rounds, smoke);
        scaleResults[scale] = r.toJson();
        lineParts.add('${scale == 'full' ? 'N=${r.n}' : 'N=$scale'} '
            '${_fmtUs(r.native.medianUs)}/${_fmtUs(r.fxdart.medianUs)}'
            '→${r.timeWinner}');
      } catch (e) {
        failures++;
        scaleResults[scale] = {'error': '$e'};
        lineParts.add('$scale FAILED: $e');
      }
    }
    cases[slug] = {
      'order': meta[slug]?.order,
      'heading': meta[slug]?.heading,
      'async': meta[slug]?.isAsync,
      'scales': scaleResults,
    };
    stdout.writeln(lineParts.join(' · '));
  }

  final results = {
    'machine': machine,
    'date': DateTime.now().toIso8601String().substring(0, 10),
    'warmup': smoke ? 0 : int.parse(Platform.environment['BENCH_WARMUP'] ?? '2'),
    'itersPerRound':
        smoke ? 1 : int.parse(Platform.environment['BENCH_ITERS'] ?? '5'),
    'tieMarginPct': tieMarginPct,
    'tieAbsMs': tieAbsMs,
    'scales': scales,
    'cases': cases,
  };
  final outDir = Directory('$root/benchmark/results')..createSync(recursive: true);
  File('${outDir.path}/results.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(results));
  File('${outDir.path}/SUMMARY.md').writeAsStringSync(_summaryMd(results, meta));
  stdout.writeln('\nWrote benchmark/results/results.json and SUMMARY.md');
  if (failures > 0) {
    stderr.writeln('$failures case×scale run(s) failed');
    exit(1);
  }
}

/// Recomputes every stored verdict from the medians already in results.json
/// and rewrites results.json + SUMMARY.md — used after a tie-rule change,
/// since verdicts are a pure function of the recorded medians.
void _reportOnly() {
  final f = File('$root/benchmark/results/results.json');
  if (!f.existsSync()) {
    stderr.writeln('no benchmark/results/results.json to re-report from');
    exit(1);
  }
  final results = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  var flips = 0;
  for (final c in (results['cases'] as Map<String, dynamic>).values) {
    final scales = (c as Map<String, dynamic>)['scales'] as Map<String, dynamic>?;
    if (scales == null) continue;
    for (final s in scales.values) {
      final sm = s as Map<String, dynamic>;
      if (sm.containsKey('error')) continue;
      final nat = sm['native'] as Map<String, dynamic>;
      final fx = sm['fxdart'] as Map<String, dynamic>;
      final time = _verdict((nat['medianUs'] as num).toDouble(),
          (fx['medianUs'] as num).toDouble(),
          absFloor: tieAbsMs * 1000.0);
      final mem = _verdict((nat['medianRssBytes'] as num).toDouble(),
          (fx['medianRssBytes'] as num).toDouble());
      if (time != sm['timeWinner'] || mem != sm['memWinner']) flips++;
      sm['timeWinner'] = time;
      sm['memWinner'] = mem;
    }
  }
  results['tieMarginPct'] = tieMarginPct;
  results['tieAbsMs'] = tieAbsMs;
  f.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(results));
  File('$root/benchmark/results/SUMMARY.md')
      .writeAsStringSync(_summaryMd(results, _loadMeta()));
  stdout.writeln('Re-derived verdicts under current rules '
      '($flips case×scale verdict(s) changed); rewrote results.json and '
      'SUMMARY.md');
}

class _SideStats {
  _SideStats(this.iterUs, this.rssBytes);
  final List<double> iterUs; // pooled across rounds, per-run µs (batch-averaged)
  final List<int> rssBytes; // one per round

  double get medianUs => _median(iterUs);
  double get medianRss => _median(rssBytes);
  Map<String, Object?> toJson() => {
        'medianUs': medianUs,
        'minUs': (iterUs.toList()..sort()).first,
        'medianRssBytes': medianRss,
        'samples': iterUs.length,
      };
}

class _ScaleResult {
  _ScaleResult(this.n, this.native, this.fxdart, this.roundsRun);
  final int n; // actual dataset size the case reported for this scale
  final _SideStats native;
  final _SideStats fxdart;
  final int roundsRun;

  String get timeWinner =>
      _verdict(native.medianUs, fxdart.medianUs, absFloor: tieAbsMs * 1000.0);
  String get memWinner => _verdict(native.medianRss, fxdart.medianRss);

  Map<String, Object?> toJson() => {
        'n': n,
        'roundsRun': roundsRun,
        'native': native.toJson(),
        'fxdart': fxdart.toJson(),
        'timeWinner': timeWinner,
        'memWinner': memWinner,
      };
}

String _verdict(double a, double b, {double absFloor = 0}) {
  final diff = (a - b).abs();
  if (diff < absFloor) return 'tie';
  if (diff / (a < b ? a : b) * 100 < tieMarginPct) return 'tie';
  return a < b ? 'native' : 'fxdart';
}

Future<_ScaleResult> _runCase(
    String slug, String scale, int baseRounds, bool smoke) async {
  final sides = {
    'native': _SideStats([], []),
    'fxdart': _SideStats([], []),
  };
  int? n;
  final checksums = <String, String>{};

  Future<void> round() async {
    for (final impl in ['native', 'fxdart']) {
      final res = await Process.run(
        _binPath(slug, impl),
        const [],
        environment: {
          if (smoke) 'BENCH_SMOKE': '1',
          if (scale != 'full') 'BENCH_N': scale,
        },
        workingDirectory: root,
      );
      if (res.exitCode != 0) {
        throw StateError('$impl exited ${res.exitCode}: ${res.stderr}');
      }
      final line = (res.stdout as String)
          .split('\n')
          .lastWhere((l) => l.startsWith(resultPrefix),
              orElse: () => throw StateError('$impl printed no result line'));
      final r =
          jsonDecode(line.substring(resultPrefix.length)) as Map<String, dynamic>;
      if (r['aot'] != true) {
        throw StateError('$impl reported a JIT (non-AOT) measurement — '
            'results must come from the compiled binaries in benchmark/.build/');
      }
      n = r['n'] as int;
      final prev = checksums[impl];
      final sum = r['checksum'] as String;
      if (prev != null && prev != sum) {
        throw StateError('$impl checksum changed between rounds ($prev → $sum)');
      }
      checksums[impl] = sum;
      sides[impl]!
          .iterUs
          .addAll((r['iterUs'] as List).map((v) => (v as num).toDouble()));
      sides[impl]!.rssBytes.add(r['maxRssBytes'] as int);
    }
    if (checksums.length == 2 && checksums['native'] != checksums['fxdart']) {
      throw StateError('checksum mismatch at N-scale $scale: '
          'native=${checksums['native']} fxdart=${checksums['fxdart']}');
    }
  }

  var roundsRun = 0;
  for (; roundsRun < baseRounds; roundsRun++) {
    await round();
  }
  // Tight relative race → gather more evidence before calling it. A tie by
  // the absolute floor needs no re-runs: more data can't make an
  // imperceptible difference perceptible. (Skipped in smoke mode.)
  if (!smoke) {
    while (roundsRun < maxRounds) {
      final a = sides['native']!.medianUs, b = sides['fxdart']!.medianUs;
      final diff = (a - b).abs();
      if (diff < tieAbsMs * 1000.0) break; // settled: imperceptible
      if (diff / (a < b ? a : b) * 100 >= tieMarginPct) break; // clear winner
      await round();
      roundsRun++;
    }
  }
  return _ScaleResult(n!, sides['native']!, sides['fxdart']!, roundsRun);
}

// --- AOT compilation --------------------------------------------------------

String _binPath(String slug, String impl) =>
    '$root/benchmark/.build/${slug}_$impl';

/// AOT-compiles every side of every selected case, 8 at a time. A binary is
/// reused when it is newer than the case's sources and the harness.
Future<void> _compileAll(List<String> slugs) async {
  Directory('$root/benchmark/.build').createSync(recursive: true);
  final harness = File('$root/benchmark/harness.dart');
  // The fxdart sides also depend on the library itself.
  var libTouched = DateTime.fromMillisecondsSinceEpoch(0);
  for (final f in Directory('$root/lib').listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart')) {
      final m = f.lastModifiedSync();
      if (m.isAfter(libTouched)) libTouched = m;
    }
  }
  final jobs = [
    for (final slug in slugs)
      for (final impl in ['native', 'fxdart']) (slug, impl),
  ];
  final pending = jobs.where((j) {
    final out = File(_binPath(j.$1, j.$2));
    if (!out.existsSync()) return true;
    final built = out.lastModifiedSync();
    if (j.$2 == 'fxdart' && libTouched.isAfter(built)) return true;
    final deps = Directory('$root/benchmark/cases/${j.$1}')
        .listSync()
        .whereType<File>()
        .followedBy([harness]);
    return deps.any((f) => f.lastModifiedSync().isAfter(built));
  }).toList();
  if (pending.isEmpty) return;

  stdout.write('Compiling ${pending.length} binaries (AOT) ');
  var next = 0;
  var failed = <String>[];
  Future<void> worker() async {
    while (next < pending.length) {
      final (slug, impl) = pending[next++];
      final res = await Process.run(
        Platform.executable,
        ['compile', 'exe', '$root/benchmark/cases/$slug/$impl.dart', '-o', _binPath(slug, impl)],
        workingDirectory: root,
      );
      if (res.exitCode != 0) {
        failed.add('$slug/$impl: ${res.stderr}');
      }
      stdout.write('.');
    }
  }

  await Future.wait([for (var i = 0; i < 8; i++) worker()]);
  stdout.writeln(' done');
  if (failed.isNotEmpty) {
    throw StateError('AOT compile failed:\n${failed.join('\n')}');
  }
}

// --- case metadata from the comparison pages --------------------------------

class _Meta {
  _Meta(this.order, this.heading, this.isAsync);
  final int order;
  final String heading;
  final bool isAsync;
}

Map<String, _Meta> _loadMeta() {
  final dir = Directory('$root/content/comparison');
  if (!dir.existsSync()) return {};
  final out = <String, _Meta>{};
  for (final f in dir.listSync().whereType<File>()) {
    if (!f.path.endsWith('.md')) continue;
    String? field(String src, String key) =>
        RegExp('^$key: (.*)\$', multiLine: true).firstMatch(src)?.group(1);
    final src = f.readAsStringSync();
    final slug = field(src, 'slug');
    if (slug == null) continue;
    out[slug] = _Meta(
      int.tryParse(field(src, 'order') ?? '') ?? 999,
      field(src, 'heading') ?? slug,
      field(src, 'async') == 'true',
    );
  }
  return out;
}

// --- reporting --------------------------------------------------------------

double _median(List<num> xs) {
  final s = xs.toList()..sort();
  final mid = s.length ~/ 2;
  return s.length.isOdd ? s[mid].toDouble() : (s[mid - 1] + s[mid]) / 2;
}

String _fmtUs(double us) {
  if (us < 1) return '${(us * 1000).toStringAsFixed(0)} ns';
  if (us < 1000) return '${us.toStringAsFixed(us < 10 ? 1 : 0)} µs';
  return '${(us / 1000).toStringAsFixed(us < 10000 ? 2 : 1)} ms';
}

String _fmtMb(double bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

String _summaryMd(Map<String, Object?> results, Map<String, _Meta> meta) {
  final machine = results['machine'] as Map<String, Object?>;
  final cases = results['cases'] as Map<String, Object?>;
  final scales = (results['scales'] as List).cast<String>();
  final b = StringBuffer()
    ..writeln('# DartComparison benchmark summary')
    ..writeln()
    ..writeln('- **Machine:** ${machine['cpu']}, ${machine['ramGb']} GB RAM')
    ..writeln('- **Dart:** ${machine['dart']} (${machine['os']}), AOT-compiled')
    ..writeln('- **Date:** ${results['date']}')
    ..writeln('- **Method:** per side and N-scale, fresh process × rounds, '
        '${results['warmup']} warmup + ${results['itersPerRound']} measured '
        'iterations per process (small N auto-batched to ≥2 ms samples); '
        'median reported. Ties — within ${results['tieMarginPct']}% of each '
        'other, or within ${results['tieAbsMs'] ?? tieAbsMs} ms absolute '
        '(beneath human perception) — with close relative races re-run up to '
        '$maxRounds rounds.')
    ..writeln('- Memory is peak process RSS — the runtime and the dataset are '
        'identical on both sides, so the *difference* is what the pipeline '
        'itself holds onto. At small N it is all runtime baseline; expect '
        'ties.');
  final rows = cases.entries.toList()
    ..sort((a, b) =>
        (meta[a.key]?.order ?? 999).compareTo(meta[b.key]?.order ?? 999));
  for (final scale in scales) {
    b
      ..writeln()
      ..writeln(scale == 'full'
          ? '## Headline N (1M sync / case-specific async)'
          : '## N = $scale')
      ..writeln()
      ..writeln('| # | Case | N | Native time | FxDart time | Time winner | '
          'Native mem | FxDart mem | Mem winner | Rounds |')
      ..writeln('|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|');
    for (final e in rows) {
      final c = e.value as Map<String, Object?>;
      final s = (c['scales'] as Map<String, Object?>)[scale];
      if (s == null) continue;
      final sm = s as Map<String, Object?>;
      final label = '${c['order']} | ${e.key}'
          '${c['async'] == true ? ' (async)' : ''}';
      if (sm.containsKey('error')) {
        b.writeln('| $label | — | FAILED: ${sm['error']} ||||||');
        continue;
      }
      final nat = sm['native'] as Map<String, Object?>;
      final fx = sm['fxdart'] as Map<String, Object?>;
      b.writeln('| $label '
          '| ${sm['n']} '
          '| ${_fmtUs((nat['medianUs'] as num).toDouble())} '
          '| ${_fmtUs((fx['medianUs'] as num).toDouble())} '
          '| **${sm['timeWinner']}** '
          '| ${_fmtMb((nat['medianRssBytes'] as num).toDouble())} '
          '| ${_fmtMb((fx['medianRssBytes'] as num).toDouble())} '
          '| ${sm['memWinner']} '
          '| ${sm['roundsRun']} |');
    }
  }
  return b.toString();
}

Map<String, Object?> _machineInfo() {
  String sysctl(String key) {
    try {
      final r = Process.runSync('sysctl', ['-n', key]);
      return (r.stdout as String).trim();
    } catch (_) {
      return '';
    }
  }

  String cpu = 'unknown';
  int ramGb = 0;
  if (Platform.isMacOS) {
    cpu = sysctl('machdep.cpu.brand_string');
    ramGb = (int.tryParse(sysctl('hw.memsize')) ?? 0) ~/ (1024 * 1024 * 1024);
  } else if (Platform.isLinux) {
    final info = File('/proc/cpuinfo');
    if (info.existsSync()) {
      cpu = RegExp(r'model name\s*:\s*(.*)')
              .firstMatch(info.readAsStringSync())
              ?.group(1) ??
          'unknown';
    }
  }
  return {
    'cpu': cpu,
    'ramGb': ramGb,
    'dart': Platform.version.split(' ').first,
    'os': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    'compilation': 'AOT (dart compile exe), enforced per result line',
  };
}
