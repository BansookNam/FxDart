// Deterministic 1,000,000-transaction sparse timeseries shared verbatim by
// both sides. The series spans a bounded 364-day (52-week) year; transactions
// land only on odd days, so every even day is a gap the pipeline must fill.
// At tiny N the span shrinks with n (multiple of 14: whole weeks AND an even
// day count, so the odd-days-only structure stays intact) — both sides read
// totalDays from here, so they stay symmetric.
import '../../harness.dart';

final n = caseN(1000000);
final int totalDays = n < 364 ? n ~/ 14 * 14 : 364; // whole weeks, even span

class Tx {
  final int day; // day of the year, 1..totalDays
  final double amount;
  const Tx(this.day, this.amount);
}

List<Tx> makeTxns() {
  final rng = Lcg(8);
  return List.generate(n, (i) {
    // Odd days only; nextDouble-based draw because the LCG's low bits cycle
    // and would leave most odd days empty too.
    final day = 1 + 2 * (rng.nextDouble() * (totalDays ~/ 2)).floor();
    return Tx(day, (100 + rng.nextInt(9900)) / 100);
  });
}
