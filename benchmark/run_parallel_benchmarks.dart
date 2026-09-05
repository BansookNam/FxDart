// ParallelComparison runner — five ways to run the same CPU-bound job.
//
// Separate from `run_benchmarks.dart` on purpose. That runner is built around
// two sides and a verdict between them: a tie margin, a winner, a per-case
// badge. This family has five sides and no winner to declare — the answer is
// a shape ("streaming already wins here", "only the batched form wins here"),
// and forcing it through a two-way verdict would throw away the thing worth
// reading.
//
// Each variant is AOT-compiled and run as its own process, like the other
// families: a JIT measurement of a 5-second workload says more about the
// compiler's warmup state than about the work.
//
// Usage:
//   dart run benchmark/run_parallel_benchmarks.dart [--smoke] [--rounds N]
//                                                   [--scales …] [slug …]
import 'dart:convert';
import 'dart:io';

import 'harness.dart' show resultPrefix;

/// The five variants, in the order the page reads them.
const impls = [
  'native',
  'native-isolate',
  'fxdart',
  'fxdart-parallel',
  'fxdart-parallel-chunk',
];

/// File name per variant — `-` is not legal in a Dart library name.
const _files = {
  'native': 'native',
  'native-isolate': 'native_isolate',
  'fxdart': 'fxdart',
  'fxdart-parallel': 'fxdart_parallel',
  'fxdart-parallel-chunk': 'fxdart_parallel_chunk',
};

/// Human labels, kept next to the results so the page does not re-invent them.
const _labels = {
  'native': 'Native, one isolate',
  'native-isolate': 'Native + dart:isolate',
  'fxdart': 'fxdart chain, one isolate',
  'fxdart-parallel': 'fxdart .parallel()',
  'fxdart-parallel-chunk': 'fxdart .parallel(chunk:)',
};

/// Case order on the page: heaviest per element first.
///
/// Alphabetical would open on the middle case and close on the one where the
/// operator loses, which reads as a warning. Cost-ordered, the three cases
/// are an argument — obviously worth it, still worth it, and here is the one
/// number that decides it. A slug not listed here sorts after these, by name.
const caseOrder = ['password-rehash', 'image-tiles', 'log-fingerprint'];

final root = File(Platform.script.toFilePath()).parent.parent.path;
const casesDir = 'benchmark/cases-parallel';

/// The headline is the scale each case sizes for a ~5 s baseline. The two
/// small ones are the other half of the answer: isolates have a fixed price
/// (~1 ms per spawn, plus copying the data in and the results out), so the
/// smaller the job the less there is left to win. Where that crosses over
/// is not guessable — it depends on the per-element cost, which is exactly
/// what these three cases vary.
const _scales = ['100', '10000', 'full'];

Future<void> main(List<String> args) async {
  var rounds = 1;
  var smoke = false;
  List<String>? scalesArg;
  final only = <String>[];
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--rounds':
        rounds = int.parse(args[++i]);
      case '--smoke':
        smoke = true;
      case '--scales':
        scalesArg = args[++i].split(',');
      default:
        only.add(args[i]);
    }
  }
  final scales = scalesArg ?? _scales;

  final slugs =
      Directory('$root/$casesDir')
          .listSync()
          .whereType<Directory>()
          .map((d) => d.path.split(Platform.pathSeparator).last)
          .where((s) => only.isEmpty || only.contains(s))
          .toList()
        ..sort((a, b) {
          final ia = caseOrder.indexOf(a);
          final ib = caseOrder.indexOf(b);
          if (ia == -1 && ib == -1) return a.compareTo(b);
          if (ia == -1) return 1;
          if (ib == -1) return -1;
          return ia.compareTo(ib);
        });
  if (slugs.isEmpty) {
    stderr.writeln('no cases in $casesDir${only.isEmpty ? '' : ' for $only'}');
    exit(1);
  }

  stdout.writeln(
    'ParallelComparison — ${slugs.length} case(s), '
    'scales ${scales.join('/')}, rounds $rounds, '
    '${Platform.numberOfProcessors} processors',
  );
  await _compileAll(slugs);

  final cases = <Map<String, dynamic>>[];
  for (final slug in slugs) {
    stdout.writeln('\n$slug');
    final scaleBlocks = <String, dynamic>{};
    for (final scale in scales) {
      scaleBlocks[scale] = await _runScale(slug, scale, rounds, smoke);
    }
    cases.add({'slug': slug, 'scales': scaleBlocks});
  }

  final out = {
    'generated': DateTime.now().toUtc().toIso8601String(),
    'workers': Platform.numberOfProcessors,
    'impls': impls,
    'labels': _labels,
    'smoke': smoke,
    'rounds': rounds,
    'cases': cases,
  };
  final f = File('$root/benchmark/results/results-parallel.json');
  f.parent.createSync(recursive: true);
  f.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
  stdout.writeln('\nwritten: ${f.path}');
}

/// One case at one scale: every variant, interleaved across [rounds].
///
/// Interleaved rather than variant-by-variant because a 5-second workload is
/// long enough for the machine to clock down inside one block, and a fixed
/// order would hand that entirely to whichever variant ran last.
Future<Map<String, dynamic>> _runScale(
  String slug,
  String scale,
  int rounds,
  bool smoke,
) async {
  final samples = {for (final i in impls) i: <double>[]};
  final checksums = <String, String>{};
  var n = 0;
  for (var r = 0; r < rounds; r++) {
    for (final impl in impls) {
      final res = await Process.run(
        _binPath(slug, impl),
        const [],
        environment: {
          if (smoke) 'BENCH_SMOKE': '1',
          // A 5-second baseline cannot afford the default 2 warmups and 5
          // iterations; the effects here are 2-4x, not the sub-5% the other
          // families have to resolve.
          if (!smoke) ...{'BENCH_WARMUP': '1', 'BENCH_ITERS': '3'},
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
            orElse: () => throw StateError('$slug/$impl printed no result'),
          );
      final rec =
          jsonDecode(line.substring(resultPrefix.length))
              as Map<String, dynamic>;
      if (rec['aot'] != true) {
        throw StateError('$slug/$impl reported a JIT measurement');
      }
      n = rec['n'] as int;
      // Every variant must compute the same answer, or the comparison is
      // between different programs.
      final sum = rec['checksum'] as String;
      final first = checksums[impls.first];
      checksums[impl] = sum;
      if (first != null && sum != first) {
        throw StateError(
          '$slug @ $scale: $impl checksum $sum != ${impls.first} $first',
        );
      }
      samples[impl]!.addAll(
        (rec['iterUs'] as List).map((e) => (e as num).toDouble()),
      );
    }
  }

  final ms = {for (final i in impls) i: _median(samples[i]!) / 1000};
  final base = ms['native']!;
  for (final i in impls) {
    final speedup = base / ms[i]!;
    stdout.writeln(
      '  ${scale.padRight(6)} ${i.padRight(22)} '
      '${ms[i]!.toStringAsFixed(1).padLeft(9)} ms  '
      '${speedup >= 1 ? '${speedup.toStringAsFixed(2)}x faster' : '${(1 / speedup).toStringAsFixed(2)}x slower'}',
    );
  }
  return {
    'n': n,
    'checksum': checksums[impls.first],
    'ms': ms,
    'speedupVsNative': {for (final i in impls) i: base / ms[i]!},
  };
}

double _median(List<double> xs) {
  final s = [...xs]..sort();
  final mid = s.length ~/ 2;
  return s.length.isOdd ? s[mid] : (s[mid - 1] + s[mid]) / 2;
}

String _binPath(String slug, String impl) =>
    '$root/benchmark/.build/parallel-$slug-${_files[impl]}';

/// AOT-compiles every variant of every selected case, 8 at a time. A binary
/// is reused when it is newer than the case's sources, the harness, and lib/.
Future<void> _compileAll(List<String> slugs) async {
  Directory('$root/benchmark/.build').createSync(recursive: true);
  final harness = File('$root/benchmark/harness.dart');
  var libTouched = DateTime.fromMillisecondsSinceEpoch(0);
  for (final f in Directory('$root/lib').listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart')) {
      final m = f.lastModifiedSync();
      if (m.isAfter(libTouched)) libTouched = m;
    }
  }
  final pending = <(String, String)>[];
  for (final slug in slugs) {
    for (final impl in impls) {
      final out = File(_binPath(slug, impl));
      if (!out.existsSync()) {
        pending.add((slug, impl));
        continue;
      }
      final built = out.lastModifiedSync();
      // Every variant here links the library: even `native.dart` pulls in the
      // harness, and the two fxdart ones pull in lib/ proper.
      if (libTouched.isAfter(built)) {
        pending.add((slug, impl));
        continue;
      }
      final deps = Directory(
        '$root/$casesDir/$slug',
      ).listSync().whereType<File>().followedBy([harness]);
      if (deps.any((f) => f.lastModifiedSync().isAfter(built))) {
        pending.add((slug, impl));
      }
    }
  }
  if (pending.isEmpty) return;

  stdout.write('Compiling ${pending.length} binaries (AOT) ');
  var next = 0;
  final failed = <String>[];
  Future<void> worker() async {
    while (next < pending.length) {
      final (slug, impl) = pending[next++];
      final res = await Process.run(Platform.executable, [
        'compile',
        'exe',
        '$root/$casesDir/$slug/${_files[impl]}.dart',
        '-o',
        _binPath(slug, impl),
      ], workingDirectory: root);
      if (res.exitCode != 0) failed.add('$slug/$impl: ${res.stderr}');
      stdout.write('.');
    }
  }

  await Future.wait([for (var i = 0; i < 8; i++) worker()]);
  stdout.writeln(' done');
  if (failed.isNotEmpty) {
    throw StateError('AOT compile failed:\n${failed.join('\n')}');
  }
}
