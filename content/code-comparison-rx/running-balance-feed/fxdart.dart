import 'package:fxdart/fxdart.dart';

// Deposits (+) and withdrawals (−) against an account opened at zero.
const moves = [250, -80, 120, -40, 500, -320, 90];

void main() {
  // scan1 folds without a separate seed — for a balance that opens at zero,
  // each partial sum IS the balance, matching Rx's one-value-per-event pace.
  final balances = scan1((acc, move) => acc + move, moves).toList();

  for (final b in balances) {
    print('Balance: $b');
  }
}
