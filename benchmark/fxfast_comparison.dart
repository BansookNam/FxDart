/// Direct performance comparison: lazy fx() vs fxFast() vs native
///
/// Compares the three optimized benchmark cases to show the performance
/// improvement of fxFast() over lazy fx() chains.

import 'dart:io';
import 'package:fxdart/fxdart.dart';

void printResult(String name, String approach, Duration elapsed, String result) {
  final ms = elapsed.inMicroseconds / 1000.0;
  print('$name ($approach): ${ms.toStringAsFixed(1)}ms - checksum: ${result.substring(0, 20)}...');
}

// ============================================================================
// Case 1: first-visit-merchants (map → uniq)
// ============================================================================

class Transaction {
  final String merchant;
  Transaction(this.merchant);
}

List<Transaction> generateTransactions(int count) =>
    List.generate(count, (i) => Transaction('Merchant #${i % 50000}'));

void benchmarkFirstVisitMerchants() {
  print('\n=== Case 1: first-visit-merchants (map → uniq) ===');
  final txns = generateTransactions(1000000);

  // Native approach
  final nativeStart = DateTime.now();
  final seen = <String>{};
  final merchants = <String>[];
  for (final t in txns) {
    if (seen.add(t.merchant)) merchants.add(t.merchant);
  }
  final nativeElapsed = DateTime.now().difference(nativeStart);
  final nativeResult = '${merchants.length}|${merchants.first}|${merchants.last}';
  printResult('first-visit-merchants', 'native', nativeElapsed, nativeResult);

  // Lazy fx approach
  final lazyStart = DateTime.now();
  final lazyMerchants = fx(txns).map((t) => t.merchant).uniq().toList();
  final lazyElapsed = DateTime.now().difference(lazyStart);
  final lazyResult = '${lazyMerchants.length}|${lazyMerchants.first}|${lazyMerchants.last}';
  printResult('first-visit-merchants', 'fx lazy', lazyElapsed, lazyResult);

  // Fast fx approach
  final fastStart = DateTime.now();
  final fastMerchants = fxFast(txns).map((t) => t.merchant).uniq().toList();
  final fastElapsed = DateTime.now().difference(fastStart);
  final fastResult = '${fastMerchants.length}|${fastMerchants.first}|${fastMerchants.last}';
  printResult('first-visit-merchants', 'fxFast', fastElapsed, fastResult);

  final lazyRatio = lazyElapsed.inMicroseconds / nativeElapsed.inMicroseconds;
  final fastRatio = fastElapsed.inMicroseconds / nativeElapsed.inMicroseconds;
  print('  Ratios: lazy ${lazyRatio.toStringAsFixed(2)}x | fxFast ${fastRatio.toStringAsFixed(2)}x');
  print('  Improvement: ${((lazyRatio - fastRatio) / lazyRatio * 100).toStringAsFixed(1)}%');
}

// ============================================================================
// Case 2: recent-errors (filter → uniqBy → take)
// ============================================================================

class LogEntry {
  final String level;
  final String message;
  final String time;
  LogEntry(this.level, this.message, this.time);
}

List<LogEntry> generateLogs(int count) => List.generate(
    count,
    (i) => LogEntry(
        i % 5 == 0 ? 'ERROR' : 'INFO',
        'Message #${i % 25000}',
        '2026-08-10T${(i % 24).toString().padLeft(2, '0')}:00:00'));

void benchmarkRecentErrors() {
  print('\n=== Case 2: recent-errors (filter → uniqBy → take) ===');
  final logs = generateLogs(1000000);

  // Native approach
  final nativeStart = DateTime.now();
  final nativeSeen = <String>{};
  final nativeRecent = <LogEntry>[];
  for (final l in logs) {
    if (l.level != 'ERROR') continue;
    if (!nativeSeen.add(l.message)) continue;
    nativeRecent.add(l);
    if (nativeRecent.length == 3) break;
  }
  final nativeElapsed = DateTime.now().difference(nativeStart);
  final nativeResult = nativeRecent.map((l) => '${l.time} ${l.message}').join('|');
  printResult('recent-errors', 'native', nativeElapsed, nativeResult);

  // Lazy fx approach
  final lazyStart = DateTime.now();
  final lazyRecent = fx(logs)
      .filter((l) => l.level == 'ERROR')
      .uniqBy((l) => l.message)
      .take(3)
      .toList();
  final lazyElapsed = DateTime.now().difference(lazyStart);
  final lazyResult = lazyRecent.map((l) => '${l.time} ${l.message}').join('|');
  printResult('recent-errors', 'fx lazy', lazyElapsed, lazyResult);

  // Fast fx approach
  final fastStart = DateTime.now();
  final fastRecent = fxFast(logs)
      .filter((l) => l.level == 'ERROR')
      .uniqBy((l) => l.message)
      .take(3)
      .toList();
  final fastElapsed = DateTime.now().difference(fastStart);
  final fastResult = fastRecent.map((l) => '${l.time} ${l.message}').join('|');
  printResult('recent-errors', 'fxFast', fastElapsed, fastResult);

  final lazyRatio = lazyElapsed.inMicroseconds / nativeElapsed.inMicroseconds;
  final fastRatio = fastElapsed.inMicroseconds / nativeElapsed.inMicroseconds;
  print('  Ratios: lazy ${lazyRatio.toStringAsFixed(2)}x | fxFast ${fastRatio.toStringAsFixed(2)}x');
  print('  Improvement: ${((lazyRatio - fastRatio) / lazyRatio * 100).toStringAsFixed(1)}%');
}

// ============================================================================
// Case 3: anomaly-context (4-op chain)
// ============================================================================

class Reading {
  final double temp;
  final String time;
  Reading(this.temp, this.time);
}

List<Reading> generateReadings(int count) => List.generate(
    count, (i) => Reading(20.0 + (i % 100) * 0.5, '2026-08-10T${(i % 24).toString().padLeft(2, '0')}:00'));

void benchmarkAnomalyContext() {
  print('\n=== Case 3: anomaly-context (4-op chain) ===');
  final readings = generateReadings(1000000);
  const limit = 40.0;

  // Native approach
  final nativeStart = DateTime.now();
  final nativeKeep = <int>{};
  for (var i = 0; i < readings.length; i++) {
    if (readings[i].temp > limit) {
      for (final j in [i - 1, i, i + 1]) {
        if (j >= 0 && j < readings.length) nativeKeep.add(j);
      }
    }
  }
  final nativeContext = <String>[];
  for (final i in nativeKeep.toList()..sort()) {
    final r = readings[i];
    final mark = r.temp > limit ? '!' : ' ';
    nativeContext.add('$mark ${r.time}  ${r.temp.toStringAsFixed(1)}°C');
  }
  final nativeElapsed = DateTime.now().difference(nativeStart);
  final nativeResult = nativeContext.isNotEmpty ? nativeContext.first : '';
  printResult('anomaly-context', 'native', nativeElapsed, nativeResult);

  // Lazy fx approach
  final lazyStart = DateTime.now();
  final lazyContext = fx(range(0, readings.length))
      .filter((i) => readings[i].temp > limit)
      .flatMap((i) => [i - 1, i, i + 1])
      .filter((i) => i >= 0 && i < readings.length)
      .uniq()
      .map((i) {
        final r = readings[i];
        final mark = r.temp > limit ? '!' : ' ';
        return '$mark ${r.time}  ${r.temp.toStringAsFixed(1)}°C';
      })
      .toList();
  final lazyElapsed = DateTime.now().difference(lazyStart);
  final lazyResult = lazyContext.isNotEmpty ? lazyContext.first : '';
  printResult('anomaly-context', 'fx lazy', lazyElapsed, lazyResult);

  // Fast fx approach
  final fastStart = DateTime.now();
  final fastContext = fxFast(range(0, readings.length))
      .filter((i) => readings[i].temp > limit)
      .map((i) => i - 1)
      .flatMap((i) => [i, i + 1, i + 2])
      .filter((i) => i >= 0 && i < readings.length)
      .uniq()
      .map((i) {
        final r = readings[i];
        final mark = r.temp > limit ? '!' : ' ';
        return '$mark ${r.time}  ${r.temp.toStringAsFixed(1)}°C';
      })
      .toList();
  final fastElapsed = DateTime.now().difference(fastStart);
  final fastResult = fastContext.isNotEmpty ? fastContext.first : '';
  printResult('anomaly-context', 'fxFast', fastElapsed, fastResult);

  final lazyRatio = lazyElapsed.inMicroseconds / nativeElapsed.inMicroseconds;
  final fastRatio = fastElapsed.inMicroseconds / nativeElapsed.inMicroseconds;
  print('  Ratios: lazy ${lazyRatio.toStringAsFixed(2)}x | fxFast ${fastRatio.toStringAsFixed(2)}x');
  print('  Improvement: ${((lazyRatio - fastRatio) / lazyRatio * 100).toStringAsFixed(1)}%');
}

void main() {
  print('''
╔════════════════════════════════════════════════════════════════╗
║ FxFast Performance Comparison: lazy fx() vs fxFast() vs native ║
╚════════════════════════════════════════════════════════════════╝
''');

  benchmarkFirstVisitMerchants();
  benchmarkRecentErrors();
  benchmarkAnomalyContext();

  print('''

Summary:
========
fxFast() provides significant performance improvements over lazy fx() chains
for set-based deduplication patterns (uniq, uniqBy), approaching native loop
performance while maintaining API composability.

Trade-offs:
- NOT lazy: materializes intermediate results to Lists
- Uses more memory: intermediate Lists are stored
- Best for hot-path code with known data sizes
- API is familiar: same methods as fx()
''');
}
